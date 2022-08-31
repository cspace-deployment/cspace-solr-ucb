#!/bin/bash -x
date
##############################################################################
# while most of this script is already tenant specific, many of the commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=public
SERVER="${CINEFILES_SERVER}"
USERNAME="${CINEFILES_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${CINEFILES_CONTACT}"
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# extract metadata and media info from CSpace
##############################################################################
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING" --pset footer -c "select * from cinefiles_denorm.doclist_view"  -o d1a.csv
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING" --pset footer -c "select * from cinefiles_denorm.filmlist_view" -o d1b.csv
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING" --pset footer -c "select * from cinefiles_denorm.filmdocs" -o d1c.csv
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING" --pset footer -f metadata_public.sql -o d1d.csv
# some fix up required, alas: data from cspace is dirty: contain csv delimiters, newlines, etc. that's why we used @@ as temporary record separator
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1a.csv | python3 computeTimeIntegersCineFiles.py docs.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1b.csv | python3 computeTimeIntegersCineFiles.py films.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1c.csv > link.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1d.csv > metadata.csv
rm d1?.csv
time psql -R"@@" -F $'\t' --pset footer -A -U $USERNAME -d "$CONNECTSTRING" -f media_public.sql -o m1.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' m1.csv > 4solr.${TENANT}.media.csv
time python3 ../common/evaluate.py 4solr.${TENANT}.media.csv /dev/null > ${TENANT}.counts.media.csv &

# special cases
cut -f1,25,26 metadata.csv > csids+docids+warcs.csv
cut -f1,5,8,14,15 4solr.${TENANT}.media.csv > csids+media_info.csv
cut -f1,2 link.csv > 4solr.${TENANT}.link.csv
perl -i -pe 's/updatedat/film_updatedat/;s/name_id/film_name_id/;' films.csv

# merge the documents, film, media (image and pdf) via the 2 "link" files
time python3 mergeObjectsAndMediaCineFiles.py 4solr.${TENANT}.media.csv link.csv csids+docids+warcs.csv films.csv docs.csv public.csv

for file in docs films metadata public
do
    # make the header
    head -1 ${file}.csv > header4Solr.csv
    # special cases (nb: some tricky regexes in here, caveat lector!)
    perl -i -pe 's/\r//;s/\t/_s\t/g;s/$/_s/;s/_ss_s/_ss/g;s/updatedat_s/updated_at_dts/g;s/_i_s/_i/g;' header4Solr.csv
    perl -i -pe 's/has_s/has_ss/;s/filmyear_s/filmyear_ss/;s/film_info_s/film_info_ss/;s/director_s/director_ss/;s/prodco(.*?)_s/prodco\1_ss/g;s/subject_s/subject_ss/g;s/genre_s/genre_ss/;s/title_s/title_ss/g;s/language_s/language_ss/g;s/country_s/country_ss/;s/name_id_s/name_id_ss/;s/author_s/author_ss/;s/film_id_s/film_id_ss/;s/doc_count_s/doc_count_ss/;' header4Solr.csv
    if [ "$file" == "films" ]; then
        # yes, sigh, it is a bit turgid here too!
        perl -i -pe 's/\ttitle/\ttitle_variations/;s/film//g;s/\t/\tfilm_/g;s/__/_/g;s/^/id\tcommon_doctype_s\t/;s/_id_ss/film_link_ss/;' header4Solr.csv
        perl -i -ne '@x=split /\t/;print "$x[0]\tfilm\t$_"' ${file}.csv
    elif [ "$file" == "public" ]; then
        perl -i -pe 's/^doc_id_s\t/id\tcommon_doctype_s\t/' header4Solr.csv
        perl -i -pe 's/^(.*?)\t/\1\tdocument\t/' ${file}.csv
    else
        perl -i -pe 's/^.*?_id_ss?\t/id\t/' header4Solr.csv
    fi
    # we want to use our "special" solr-friendly header.
    tail -n +2 ${file}.csv | grep -v " rows)" > d7.csv
    cat header4Solr.csv d7.csv > 4solr.${TENANT}.${file}.csv
    cat header4Solr.csv
    time python3 ../common/evaluate.py 4solr.${TENANT}.${file}.csv /dev/null > ${TENANT}.counts.${file}.csv &
done
wait
# tidy up a bit
rm d?.csv m1.csv header4Solr.csv
##############################################################################
# first, however, save (hide) the 'films' file
##############################################################################
gzip -f 4solr.${TENANT}.films.csv
##############################################################################
# OK, we are good to go! clear out the existing data and reload
##############################################################################
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  50000 48
##############################################################################
# now, restore the 'films' file and load it
##############################################################################
gunzip 4solr.${TENANT}.films.csv.gz
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  30000  0 films
# moving .csv files and saving the extract is done in post_to_solr!
date

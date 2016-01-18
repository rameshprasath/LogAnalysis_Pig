
%declare INPUTPATH_WC './output/wordcnt_';
%declare INPUT_WC_FILE '/part-r-00000';
%declare OUTPUT_MM './output/minmax_';

lf = LOAD '$INPUTPATH_WC$cnt$INPUT_WC_FILE' USING PigStorage ('$') AS (pos:int, word:chararray, cnt:int);

woword = FOREACH lf GENERATE pos, cnt;

dcnt = distinct woword;

gp1 = GROUP dcnt BY pos;

gp2 = FOREACH gp1 GENERATE group, MIN(dcnt.cnt), MAX(dcnt.cnt);

STORE gp2 INTO '$OUTPUT_MM$cnt' using PigStorage('$');


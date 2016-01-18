
REGISTER PigUDFUtils.jar

DEFINE wordBag com.loganalysis.PigUDFs.WordBag();

%declare OUTPUTPATH_LW './output/lw_';
%declare OUTPUTPATH_WC './output/wordcnt_';

lf = LOAD '$input' AS (msg: chararray);
logmsg = FOREACH lf GENERATE flatten(TRIM(REPLACE(msg, '[0-9]+:[0-9]+:[0-9]+.[0-9]+\\s+\\[[0-9]+.[0-9]+\\]\\s+<[0-9]+>', ''))) AS msg;
logwords = FOREACH logmsg GENERATE wordBag() as b:{(lnum:int, word:chararray, pos:int)};
STORE logwords INTO '$OUTPUTPATH_LW$cnt' using PigStorage('$');


fw = FOREACH logwords GENERATE flatten(b) as (lnum:int, word:chararray, pos:int);

gp1 = group fw by (pos, word);

gp2 = FOREACH gp1 GENERATE group.pos, group.word, COUNT(fw) as cnt;

STORE gp2 INTO '$OUTPUTPATH_WC$cnt' using PigStorage('$');



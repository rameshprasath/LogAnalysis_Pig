REGISTER PigUDFUtils.jar
--REGISTER /home/cloudera/.m2/repository/com/google/code/gson/gson/2.3.1/gson-2.3.1.jar

DEFINE SaveTrieNode com.loganalysis.PigUDFs.CreateTrieNode();

%declare INPUTPATH_WC './output/wordcnt_';
%declare INPUT_RED_FILE '/part-r-00000';
%declare INPUTPATH_LW './output/lw_';
%declare INPUT_MAP_FILE '/part-m-00000';
%declare INPUT_MM './output/minmax_';
%declare OUTPUTPATH_CG './output/clustergen_'


lm = LOAD '$INPUTPATH_LW$cnt$INPUT_MAP_FILE' USING PigStorage ('$') AS b:{(lnum:int, word:chararray, pos:int)};

logwords = LOAD '$INPUTPATH_WC$cnt$INPUT_RED_FILE' USING PigStorage ('$') AS (pos:int, word:chararray, cnt:int);

lf = LOAD '$INPUT_MM$cnt$INPUT_RED_FILE' USING PigStorage ('$') AS (pos:int, mincnt:float, maxcnt:float);

jn1 = JOIN logwords BY pos, lf BY pos;

swd = FOREACH jn1 GENERATE logwords::pos as pos, word, cnt as absfreq, ((cnt-mincnt)/(maxcnt-mincnt == 0 ? 1 : maxcnt-mincnt)) as normfreq;

out1 = FOREACH lm generate flatten(b) as (lnum:int, word:chararray, pos:int);

jn2 = JOIN out1 by (pos,word), swd by(pos,word);

out2 = FOREACH jn2 GENERATE out1::lnum as lnum, swd::pos as pos, out1::word as word, swd::absfreq as absfreq, swd::normfreq as normfreq;

gp1 = GROUP out2 BY lnum;

out3 = FOREACH gp1 {
		sorted = ORDER out2 BY pos ASC;
		GENERATE group as lnum, sorted;
	};

out4 = FOREACH out3 GENERATE SaveTrieNode(sorted);
STORE out4 INTO '$OUTPUTPATH_CG$cnt' using PigStorage('$');;

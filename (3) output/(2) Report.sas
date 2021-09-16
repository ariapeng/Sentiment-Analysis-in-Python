***Section_2    Yahui_Peng    @ifg583***;

proc means data = clean noprint;
class grades;
var emotionality;
output out = output n=Count mean=Average std=stdev min=Minimum max=Maximum; 
run;

proc sort data = output;
by descending _type_ grades;
run;

data summary (drop = _TYPE_ _FREQ_);
set output;
by descending _type_ grades;
if _TYPE_ = 0 then grades = -1;
format average stdev minimum maximum 8.2;
run;

options center nodate nonumber; 
ods noproctitle;
ods escapechar='^';
ods trace on;

proc anova data = clean outstat = est;
class grades;
model emotionality = grades;
quit;

ods rtf file = "&out\OneWay_Emotionality_Grades.rtf" startpage=yes bodytitle;
proc print data=summary noobs split='/';
var grades / 
style(header) = {font=("Times New Roman",11pt,bold) foreground=black background=LTGRAY just=l}
style(data) = {font=("Times New Roman",11pt,bold) foreground=black background=LTGRAY just=l};
var count average stdev minimum maximum/
style(header) = {font=("Times New Roman",11pt,bold) foreground=black background=LTGRAY just=r}
style(data) = {font=("Times New Roman",10pt) foreground=black just=r};
label grades="Groups" count="Count" average="Average" stdev="Standard/Deviation" Minimum="Minimum" Maximum="Maximum";
title font=Times height=13pt color=BL "^\i^\b Summary Statistics of Emotionality across Grades";
run;
title;

ods text = "^S={fontsize = 12pt}A one-way ANOVA comparing the effects Grades on Emotionality was performed. There was not a significant effect of Grades on Emotionality for the 8 levels ^\b[F(7,264) = 1.31, p= 0.2453]^\b0. A graph of results can be seen below.";

proc anova data = clean;
class grades;
model emotionality = grades;
ods select boxplot;
run;
quit;

ods rtf close;
ods trace off;
quit;

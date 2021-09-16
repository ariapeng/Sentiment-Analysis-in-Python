***Section_3   Yahui_Peng    ifg583***;

%macro oneway(dep = Emotionality,ind = Runaway);
proc means data = clean noprint;
class &ind.;
var &dep.;
output out = output n=Count mean=Average std=Stdev min=Minimum max=Maximum; 
run;

proc sort data = output;
by descending _type_ &ind.;
run;

data summary (drop = _TYPE_ _FREQ_);
set output;
by descending _type_ &ind.;
if _TYPE_ = 0 then &ind. = -1;
format average stdev minimum maximum 8.2;
run;

options center nodate nonumber; 
ods noproctitle;
ods escapechar='^';
ods trace on;

proc anova data = clean outstat = est;
class &ind.;
model &dep. = &ind.;
run;
quit;

data _null_;
set est;
if _TYPE_ = "ERROR" then call symputx("df2",df);
else do;
call symputx("df1",df);
k = df + 1;
call symputx("k",k);
call symputx("f",round(F,0.01));
call symputx("p_val",put(Prob,PVALUE9.4));
end;
if Prob < 0.05 then call symputx("sgfnt","was"); 
else call symputx("sgfnt","was not");
run;

ods rtf file = "&out\OneWay_&dep._&ind. .RTF" startpage=yes bodytitle;
proc print data=summary noobs split='/';
var &ind. / 
style(header) = {font=("Times New Roman",11pt,bold) foreground=black background=LTGRAY just=l}
style(data) = {font=("Times New Roman",11pt,bold) foreground=black background=LTGRAY just=l};
var count average stdev minimum maximum/
style(header) = {font=("Times New Roman",11pt,bold)foreground = black background = LTGRAY just = r}
style(data) = {font=("Times New Roman",10pt) foreground = black just = r};
label &ind. = "Groups" count = "Count" average = "Average"
stdev = "Standard/Deviation" Minimum = "Minimum" Maximum = "Maximum";
title font=Times height=13pt color=BL "^\i^\b Summary Statistics of &dep. across &ind.";
run;

title;
ods text = "^S={fontsize = 12pt}A one-way ANOVA comparing the effects &ind. on &dep. was performed. There &sgfnt. a significant effect of &ind. on &dep. for the &k. levels ^\b[F(&df1.,&df2.) = &f., p = &p_val.]^\b0. A graph of results can be seen below.";

proc anova data = clean;
class &ind.;
model &dep. = &ind.; 
ods select boxplot;
run;
quit;

ods rtf close;
ods trace off;
quit;
%mend;

%oneway();
%oneway(ind = Brothers);
%oneway(ind = ADHD);
%oneway(ind = Ethnicity);
quit;

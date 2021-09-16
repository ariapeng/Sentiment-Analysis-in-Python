/*Peng_Yahui | ID_ifg583 | EXE5*/

libname ex excel "\\Client\C$\SAS\Module_05\Exercise 5 - Student Answers.xlsx";

data answer;
set ex.'Sheet1$'n;
run;

data total;
set answer;
array Q(20) $ Question_1-Question_20;
array Key(20) $ _temporary_ ("A" "C" "A" "A" "B" "C" "D" "D" "D" "A" "C" "B" "A" "D" "B" "C" "C" "A" "A" "A");
array S(20) Score1-Score20;
Grade = 0;
do i = 1 to 20;
if Q(i) = Key(i) then S(i) = 1;
else S(i) = 0;
Grade + S(i);
end;
run;

proc print data = total noobs;
id Student_ID;
var Score1-Score20;
sum Score1-Score20;
title "Total Correct by Item";
footnote; /*After having run the whole program, if I run this part individually, 
the footnote of below table will always show under this table. I guess it'd be better to clear all footnotes here*/
run;

proc sort;
by Gender;
run;

proc print;
id Student_ID;
by Gender;
sum Grade;
var Gender Grade;
title "Total Grade Grouped by Gender";
footnote "Poor Performance Groups";
run;

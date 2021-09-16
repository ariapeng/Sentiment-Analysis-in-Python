/*Lecture 5
Arrays
*/
data new;
array zero{8} zero1-zero8;
do i= 1 to 8;
zero{i}=0;
end;
run;

array cresp[*] $ sq1 sq2 sq3;
do i = 1 to DIM(cresp);
run;

DATA PASSING; 
ARRAY PASS[5] _TEMPORARY_ (65 70 65 80 75); 
ARRAY SCORE[5]; 
INPUT ID $ SCORE[*]; 
PASS_NUM = 0; 
DO I=1 TO 5; 
IF SCORE[I] GE PASS[I] THEN PASS_NUM + 1; 
END;
DROP I; 
DATALINES; 
001 64 69 68 82 74 
002 80 80 80 60 80 
; 
PROC PRINT DATA=PASSING; 
TITLE "Passing Data Set"; 
ID ID; 
VAR PASS_NUM SCORE1-SCORE5; 
RUN; 

/*Transpose - wide to long*/
DATA manyobs (keep = subjid score examno);
array ex(6) exam1-exam6;
input subjid $ exam1 exam2 exam3 exam4 exam5 exam6;
do i = 1 to 6;
examno = i;
score = ex(i);
if score ne . then output;
end;
drop i exam-exam6;
datalines;
29 67 86 67 76 79 80
31 79 70 76 76 79 77
;
proc print data=manyobs;
run;


/*Long to wide, more complicated*/
proc sort data = manyobs;
by subjid examno;
DATA transpose (keep = subjid exam1-exam6);
array exam(6) exam1-exam6;
retain exam1-exam6;
set manyobs;
by subjid;
exam(examno) = score;
if last.subjid then output; *important;
run;

proc print data=transpose;
run;


/*Reading in Excel file and recoding -1 to missing for each variable*/
libname ex xlsx "\\client\c$\SAS\Module_05\Minus1.xlsx"; /*or libname ex excel "\\client\c$\sas\Module_05\minus.xlsx" */

data minus;
set ex.'sheet1$'n;
run;

data recode;
set minus;
array Q{66} Question_01 - Question_66;
do i = 1 to 66;
if Q[i] = -1 then Q[i] = .;
end;
run;
proc print;
run;



/*Example 1*/

/*Convert all values of "1" to "0"*/
proc contents data = mysas.survey1;
run;
proc print data = mysas.survey1;
run;

data survey1;
set mysas.survey1(drop = Subj);
array a{5} $ _CHARACTER_;
do i = 1 to 5;
if a[i] = "1" then a[i] = "0";
end;
run;
proc print data = survey1;
run;


/*Example 2 */

***Create data set Original;
data Original;
   input X Y A $ X1-X3 Z $;
datalines;
1 2 x 3 4 5 Y
2 999 y 999 1 999 J
999 999 R 999 999 999 X
1 2 yes 4 5 6 No
;

proc print data = Original;
proc contents data = Original;
run;


*Converting all Values of 999 to Missing and 
converting all Character Values to Uppercase;

data new;
set original;
array num{*} _NUMERIC_;
array char{*} _CHARACTER_;
do i = 1 to DIM(num);
if num[i] = 999 then num[i] = .;
end;

do j = 1 to DIM(char);
char[j] = upcase(char[j]);
end;

run;
proc print data = new;
run;


/*PROC SORT, Titles, and PRINT Options*/

%let mydir = \\Client\C$\SAS;
%let Text = &mydir.\Text and CSV;
libname mysas "&mydir\SAS datasets";

/*Add Clinic to your dataset*/
proc format;
   value $dx 1 = 'Routine Visit'
             2 = 'Cold'
             3 = 'Heart Problems'
             4 = 'GI Problems'
             5 = 'Psychiatric'
             6 = 'Injury'
             7 = 'Infection';
run;
data clinic;
   input ID : $5.
         VisitDate : mmddyy10.
         Dx : $3.
         HR SBP DBP;
   format VisitDate mmddyy10.
          Dx $dx.;
datalines;
101 10/21/2005 4 68 120 80
255 9/1/2005 1 76 188 100
255 12/18/2005 1 74 180 95
255 2/1/2006 3 79 210 110
255 4/1/2006 3 72 180 88
101 2/25/2006 2 68 122 84
303 10/10/2006 1 72 138 84
409 9/1/2005 6 88 142 92
409 10/2/2005 1 72 136 90
409 12/15/2006 1 68 130 84
712 4/6/2006 7 58 118 70
712 4/15/2006 7 56 118 72
;
proc sort data = clinic;
by descending ID descending VisitDate;
run;

proc print noobs;
id ID;
by descending ID;
sum HR;
run;



/*Titles will stay in place until you call the same title statement.
Once a Title(n) statement is called, all titles > n note called will be
removed*/
title1 "Clinic Dataset";
title2 "SAS Class Example";
title3 "Dr. Michael Sanchez";
proc print data = clinic (Firstobs = 3 Obs = 10) noobs label;
*ID ID;
var VisitDate Dx;
where HR < 70;
format VisitDate date10.;
label Dx = "Diagnosis";
run;

/*Titles will stay in place until you call the same title statement.
Once a Title(n) statement is called, all titles > n note called will be
removed unless edited*/
title1 "Clinic Dataset";
title2 "SAS Class Example";
title3 "Professor Sanchez";
proc print data = clinic (Firstobs = 1 Obs = 2) noobs;
run;
title "Clinic Dataset"; /*title is the same as title1*/
/*Again, once title(n) is called, all other titles > n are removed*/
title3 "Professor Sanchez";
footnote1 "mysasing about Titles";
proc print data = clinic (Firstobs = 1 Obs = 2) noobs;
run;

title2 "SAS Class Example"; /*Does this remove title1?*/
							/*What happens to the footnote*/
proc print data = clinic (Firstobs = 1 Obs = 2) noobs;
run;
title;footnote; /*Clears out all titles and footnotes*

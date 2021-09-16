/*SECTION_1   Yahui_Peng   @ifg583*/

%let mydir = \\Client\C$\SAS\Final Project; 
%let in = &mydir\(1) input;
%let out = &mydir\(3) output;
libname input "&in";

Proc format;
value runaway             -1 = "Overall" 
                           1 = "Once"
                           2 = "Two or three times"
						   3 = "More than 3 times";
value income              -1 = "Overall"
                           1 = "$7,500 or less per year"
                           2 = "$7,501 - $15,000"
			               3 = "$15,001 - $25,000"
			               4 = "$25,001 - $35,000"
			               5 = "$35,001 - $50,000"
			               6 = "$50,001 - $75,000"
			               7 = "$75,001 or more";
value children            -1 = "Overall"
                           0 = "No"
                           1 = "Yes";
value child_support       -1 = "Overall"
                           0 = "No"
                           1 = "Yes";
value grade_level         -1 = "Overall"
                           1 = "6th grade or less"
                           2 = "7th grade"
						   3 = "8th grade"
						   4 = "9th grade"
						   5 = "10th grade"
						   6 = "11th grade"
						   7 = "High school graduate";
value grades              -1 = "Overall" 
                           1 = "Mostly A's"
                           2 = "About half A's and half B's"
						   3 = "Mostly B's"
				  	 	   4 = "About half B's and half C's"
					 	   5 = "Mostly C's"
						   6 = "About half C's and half D's"
						   7 = "Mostly D's"
						   8 = "Mostly below D's";
value adhd                -1 = "Overall"
                           1 = "ADHD Combined Type"
                           2 = "ADHD Inattentive Type"
						   3 = "ADHD Hyperactive_Impulsive Type"
						   5 = "No";
value gender              -1 = "Overall"
                          -9 = "Don't know"
                          -8 = "Refusal" 
                           1 = "Males"
                           2 = "Females";
value ethnicity           -1 = "Overall"
                           1 = "White"
                           2 = "Black"
                           3 = "Hispanic"
                           4 = "Other"; 
run;

data demog;
infile "&in\demographics.csv" dsd truncover firstobs=2;
input ID Name : $30. Birthdate : mmddyy10. Survey_Year Survey_Month Survey_Day Street_Number Street_Name : $30. Zipcode Gender Ethnicity;
if ID = 51284 then birthdate = mdy(11,8,1990);
else if ID = 54740 then birthdate = mdy(12,18,1989);
if survey_year = 7 then survey_year = 2007;
if gender = 3 then gender = -9;
if ethnicity = 0 then ethnicity = .;
format  birthdate mmddyy10. gender gender. ethnicity ethnicity.;
label ID = "Subject ID" Name = "Subject name, last name first" Birthdate = "Subject birth data"
Survey_Year = "Year the survey was collected" Survey_Month = "Month the survey was collected"
Survey_Day = "Day the survey was collected" Street_Number = "Street number of where the subject lives"
Street_Name = "Street where the subject lives" Zipcode = "Zip code of were the subject lives"
Gender = "Subject gender" Ethnicity = "Subject ethinicity";
run;

data bkgrd_1 (drop = Brothers rename =(bro = Brothers)); 
set input.background_part1;
bro = input(compress(Brothers),8.);
label bro = "Number of brothers the subject has";
run;

data bkgrd_2 (drop = Self_regulation rename =(self_reg = Self_regulation));
set input.background_part2;
Self_reg = input(compress(Self_regulation),8.);
label Self_reg = "Self-regulation scale";
run;

data bkgrd (rename = (caseid = ID));
set bkgrd_1 bkgrd_2;
array c(18) _numeric_;
do i=1 to dim(c);
if c(i) < 0 then c(i) = .;
end;
drop i;
if runaway = 3 then runaway = 2;
else if runaway > 3 then runaway = 3;
if child_support > 1 then child_support = 1;
if grade_level > 7 then grade_level = 7;
if age_first_arrest < age_first_offense then age_first_offense = age_first_arrest;
if friends > 50 then friends = 50;
if detention_jail > 10 then detention_jail = 10; 
format runaway runaway. income income. children children. child_support child_support. grade_level grade_level. grades grades. adhd adhd.;
run;

proc sort data = demog; 
by ID;
run;
proc sort data = bkgrd;
by ID;
run;

data clean;
merge demog(in=a)
bkgrd (in=b);
by ID;
if a and b;
if id = 54411 and ethnicity = . then delete;
run;

proc print data = clean;
var ID Name Birthdate Survey_Year Survey_Month Survey_Day Street_Number Street_Name Zipcode Gender Ethnicity
runaway Living_in_household income children Child_support Brothers Sisters Grade_level Grades Age_first_Offense 
Self_regulation ADHD Emotionality Age_first_arrest Friends Number_of_arrests Detention_jail; 
run;

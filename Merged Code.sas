/* Analysis of US Youth Violence Data */
/* Section 1 - Data cleaning */
* create macro variables to hold directory paths ;
%let mydir = /home/u49400069/UTSA Course/Final Project;
%let in = &mydir/(1) input;
%let out = &mydir/(3) output;
* create a library in the directory &in ;
libname input "&in";
* create formats for character variables ;

Proc format;
	value runaway             -1="Overall" 1="Once" 2="Two or three times" 
		3="More than 3 times";
	value income              -1="Overall" 1="$7,500 or less per year" 
		2="$7,501 - $15,000" 3="$15,001 - $25,000" 4="$25,001 - $35,000" 
		5="$35,001 - $50,000" 6="$50,001 - $75,000" 7="$75,001 or more";
	value children            -1="Overall" 0="No" 1="Yes";
	value child_support       -1="Overall" 0="No" 1="Yes";
	value grade_level         -1="Overall" 1="6th grade or less" 2="7th grade" 
		3="8th grade" 4="9th grade" 5="10th grade" 6="11th grade" 
		7="High school graduate";
	value grades              -1="Overall" 1="Mostly A's" 
		2="About half A's and half B's" 3="Mostly B's" 
		4="About half B's and half C's" 5="Mostly C's" 
		6="About half C's and half D's" 7="Mostly D's" 8="Mostly below D's";
	value adhd                -1="Overall" 1="ADHD Combined Type" 
		2="ADHD Inattentive Type" 3="ADHD Hyperactive_Impulsive Type" 5="No";
	value gender              -1="Overall"
                          -9="Don't know"
                          -8="Refusal" 1="Males" 
		2="Females";
	value ethnicity           -1="Overall" 1="White" 2="Black" 3="Hispanic" 
		4="Other";
run;

* create a dataset demog ;

data demog;
	infile "&in\demographics.csv" dsd truncover firstobs=2;
	input ID Name : $30. Birthdate : mmddyy10. Survey_Year Survey_Month Survey_Day 
		Street_Number Street_Name : $30. Zipcode Gender Ethnicity;
	* refine abnormal values;
	* Birthdate value of 11/8/990 and 12/18/989 were replaced with 

		11/8/1990 and 12/18/1989 assuming 1 was accidentally omitted;

	if ID=51284 then
		birthdate=mdy(11, 8, 1990);
	else if ID=54740 then
		birthdate=mdy(12, 18, 1989);
	* Survey_Year of value 7 was replaced with 2007, assuming 200 was accidentally omitted;

	if survey_year=7 then
		survey_year=2007;
	* Gender takes meaningful values in (-9, -8, 1, 2). 
Therefore, 3 was replaced with -9, assuming a negative sign was accidentally omitted;

	if gender=3 then
		gender=-9;
	* Ethnicity takes meaningful values in (1, 2, 3, 4). Thus, 0 was replaced with a missing value;

	if ethnicity=0 then
		ethnicity=.;
	* permanently associate a format with var Birthdate, Gender, Ethnicity;
	format birthdate mmddyy10. gender gender. ethnicity ethnicity.;
	* associate labels with all vars;
	label ID="Subject ID" Name="Subject name, last name first" 
		Birthdate="Subject birth data" Survey_Year="Year the survey was collected" 
		Survey_Month="Month the survey was collected" 
		Survey_Day="Day the survey was collected" 
		Street_Number="Street number of where the subject lives" 
		Street_Name="Street where the subject lives" 
		Zipcode="Zip code of were the subject lives" Gender="Subject gender" 
		Ethnicity="Subject ethinicity";
run;

* create a dataset bkgrd_1 ;

data bkgrd_1 (drop=Brothers rename=(bro=Brothers));
	set input.background_part1;
	bro=input(compress(Brothers), 8.);
	* remove blanks and convert to numeric;
	label bro="Number of brothers the subject has";
run;

* create a dataset bkgrd_2 ;

data bkgrd_2 (drop=Self_regulation rename=(self_reg=Self_regulation));
	set input.background_part2;
	Self_reg=input(compress(Self_regulation), 8.);
	* remove blanks and convert to numeric;
	label Self_reg="Self-regulation scale";
run;

* append bkgrd_1 and bkgrd_2;

data bkgrd (rename=(caseid=ID));
	set bkgrd_1 bkgrd_2;
	array c(18) _numeric_;
	* create an array to convert all negative numeric values to missing;

	do i=1 to dim(c);

		if c(i) < 0 then
			c(i)=.;
	end;
	drop i;
	* refine abnormal values;
	* Runaway takes meaningful values in (1, 2, 3). Thus, the value of 0 was replaced with a missing value;

	if runaway=3 then
		runaway=2;
	else if runaway > 3 then
		runaway=3;
	* Child_support takes meaningful values in (0, 1). Values > 1 were replaced with 1;

	if child_support > 1 then
		child_support=1;
	* Grade_level takes meaningful values in (1-7). Values greater than 7 were replaced with 7;

	if grade_level > 7 then
		grade_level=7;
	* Age_first_arrest < Age_first_offense isn’t reasonable, use IF-THEN to set them equal;

	if age_first_arrest < age_first_offense then
		age_first_offense=age_first_arrest;
	* Friends = 1000 is unreasonable. Recode it to the second maximum number 50;

	if friends > 50 then
		friends=50;
	* Detention_jail = 101 is unreasonable. Recode it to the second maximum number 10;

	if detention_jail > 10 then
		detention_jail=10;
	* associate labels with all vars;
	format runaway runaway. income income. children children. child_support 
		child_support. grade_level grade_level. grades grades. adhd adhd.;
run;

* sort the data sets by ascending ID;

proc sort data=demog;
	by ID;
run;

proc sort data=bkgrd;
	by ID;
run;

* merge datasets demog and bkgrd by ID;

data clean;
	merge demog(in=a) bkgrd (in=b);
	by ID;

	if a and b;
	* keep observations IDs in both demog and bkgrd;

	if id=54411 and ethnicity=. then
		delete;
	* frequency table of ID shows duplicated ID = 54411. The ob with missing ethnicity is deleted;
run;

* display all vars in CLEAN in arranged order;

proc print data=clean;
	var ID Name Birthdate Survey_Year Survey_Month Survey_Day Street_Number 
		Street_Name Zipcode Gender Ethnicity runaway Living_in_household income 
		children Child_support Brothers Sisters Grade_level Grades Age_first_Offense 
		Self_regulation ADHD Emotionality Age_first_arrest Friends Number_of_arrests 
		Detention_jail;
run;

/* Section 2 - Output an RTF file */
* analyze summary statistics for dataset CLEAN;

proc means data=clean noprint;
	class grades;
	var emotionality;
	output out=output n=Count mean=Average std=stdev min=Minimum max=Maximum;
run;

* sort the OUTPUT data set by descending _type and ascending Grades;

proc sort data=output;
	by descending _type_ grades;
run;

* create a dataset Summary using Output data;

data summary (drop=_TYPE_ _FREQ_);
	set output;
	* Read data from the dataset output;
	by descending _type_ grades;
	* assign -1 to grades if _type_ = 0. 
According to the PROC FORMAT VALUE part in Section 1., grades taking a value of -1 is formatted to output “Overall”;

	if _TYPE_=0 then
		grades=-1;
	format average stdev minimum maximum 8.2;
run;

options center nodate nonumber;
ods noproctitle;
ods escapechar='^';
ods trace on;
* one-way ANOVA test;

proc anova data=clean outstat=est;
	class grades;
	model emotionality=grades;
quit;

* create an RTF file;
* STARTPAGE=YES option lets a later boxplot display on a new page;
* BODYTITLE option lets the title display as a bodytitle other than a header;
ods rtf file="&out\OneWay_Emotionality_Grades.rtf" startpage=yes bodytitle;

proc print data=summary noobs split='/';
	var grades / style(header)={font=("Times New Roman", 11pt, bold) 
		foreground=black background=LTGRAY just=l} 
		style(data)={font=("Times New Roman", 11pt, bold) foreground=black 
		background=LTGRAY just=l};
	* customize font, color, and style for all vars;
	var count average stdev minimum maximum/ 
		style(header)={font=("Times New Roman", 11pt, bold) foreground=black 
		background=LTGRAY just=r} style(data)={font=("Times New Roman", 10pt) 
		foreground=black just=r};
	label grades="Groups" count="Count" average="Average" 
		stdev="Standard/Deviation" Minimum="Minimum" Maximum="Maximum";
	title font=Times height=13pt color=BL 
		"^\i^\b Summary Statistics of Emotionality across Grades";
run;

title;
ods text="^S={fontsize = 12pt}A one-way ANOVA comparing the effects Grades on Emotionality was performed. There was not a significant effect of Grades on Emotionality for the 8 levels ^\b[F(7,264) = 1.31, p= 0.2453]^\b0. A graph of results can be seen below.";
* One-way ANOVA was again performed;

proc anova data=clean;
	class grades;
	model emotionality=grades;
	ods select boxplot;
	* output the generated graph to the RTF file;
	run;
quit;

ods rtf close;
ods trace off;
quit;

/* Section 3 Create a macro */
* create a macro oneway to soft code Section_2;
* find all text “emotionality” and “grades” and replace them with the macro variables &dep. and &ind.;
* copy the code in Section_2 into Section_3;

%macro oneway(dep=Emotionality, ind=Runaway);
	proc means data=clean noprint;
		class &ind.;
		var &dep.;
		output out=output n=Count mean=Average std=Stdev min=Minimum max=Maximum;
	run;

	proc sort data=output;
		by descending _type_ &ind.;
	run;

	data summary (drop=_TYPE_ _FREQ_);
		set output;
		by descending _type_ &ind.;

		if _TYPE_=0 then
			&ind.=-1;
		format average stdev minimum maximum 8.2;
	run;

	options center nodate nonumber;
	ods noproctitle;
	ods escapechar='^';
	ods trace on;

	proc anova data=clean outstat=est;
		class &ind.;
		model &dep.=&ind.;
		run;
	quit;

	* create a null dataset _null_ to define macro variables;

	data _null_;
		set est;
		* read data from EST output from ANOVA test;
		* if _type_ = “error”, then a CALL SYMPUTX() statement was used to 
convert df variable to a macro variable &df2, which represents the second degree of freedom,
else then a CALL SYMPUTX() statement was used to 
convert df variable to a macro variable &df1, which represents the first degree of freedom;

		if _TYPE_="ERROR" then
			call symputx("df2", df);
		else
			do;
				call symputx("df1", df);
				k=df + 1;
				* assign a new variable k with the value of df + 1, which represents the level;
				call symputx("k", k);
				call symputx("f", round(F, 0.01));
				call symputx("p_val", put(Prob, PVALUE9.4));
			end;
		* for different test result, assign different values to &sgfnt;

		if Prob < 0.05 then
			call symputx("sgfnt", "was");
		else
			call symputx("sgfnt", "was not");
	run;

	ods rtf file="&out\OneWay_&dep._&ind. .RTF" startpage=yes bodytitle;

	proc print data=summary noobs split='/';
		var &ind. / style(header)={font=("Times New Roman", 11pt, bold) 
			foreground=black background=LTGRAY just=l} 
			style(data)={font=("Times New Roman", 11pt, bold) foreground=black 
			background=LTGRAY just=l};
		var count average stdev minimum maximum/ 
			style(header)={font=("Times New Roman", 11pt, bold)foreground=black 
			background=LTGRAY just=r} style(data)={font=("Times New Roman", 10pt) 
			foreground=black just=r};
		label &ind.="Groups" count="Count" average="Average" 
			stdev="Standard/Deviation" Minimum="Minimum" Maximum="Maximum";
		title font=Times height=13pt color=BL 
			"^\i^\b Summary Statistics of &dep. across &ind.";
	run;

	title;
	ods text="^S={fontsize = 12pt}A one-way ANOVA comparing the effects &ind. on &dep. was performed. There &sgfnt. a significant effect of &ind. on &dep. for the &k. levels ^\b[F(&df1.,&df2.) = &f., p = &p_val.]^\b0. A graph of results can be seen below.";

	proc anova data=clean;
		class &ind.;
		model &dep.=&ind.;
		ods select boxplot;
		run;
	quit;

	ods rtf close;
	ods trace off;
	quit;
%mend;

* end the %macro statement;
* run the macro with designated arguments;
%oneway();
%oneway(ind=Brothers);
%oneway(ind=ADHD);
%oneway(ind=Ethnicity);
quit;
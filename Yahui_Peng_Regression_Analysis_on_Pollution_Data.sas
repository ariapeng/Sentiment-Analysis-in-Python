/* Regression Analysis on Pollution Data */
/* STA-6013 Regression Analysis */
/* Yahui Peng */

/* 1. import database */
filename reffile '/home/u49400069/Regression Analysis/Final_Project/Final_Project.xls';
proc import datafile=reffile
	dbms=xls
	out=work.pollution;
	getnames=yes;
run;
proc print data=work.pollution;run;
proc contents data=work.pollution; run;


/* 2. investigation of the data */
/* boxplots */
data long;
    set pollution;
    array tm(*) x1 - x5;
    do i=1 to dim(tm);
        predictor=compress(vname(tm(i)), 'kd');
        Value=tm(i);
        output;
    end;
    keep predictor value;
    run;

proc sgplot data=long;
    vbox value / group=predictor;
run;

proc sgplot data=have;
    vbox x1-x5;
run;

* correlation table & scatter plots ;
proc corr data=pollution plots=matrix(histogram nvar=all);
run;

* loess plots ;
proc sgplot data=pollution;
	reg x=x1 y=y / clm cli;
run;

proc loess data=pollution;
	model y=x1/smooth=0.1 0.2 0.4 0.6 0.8 1.0;
run;

proc sgplot data=pollution;
	reg x=x2 y=y / clm cli;
run;

proc loess data=pollution;
	model y=x2/smooth=0.1 0.2 0.4 0.6 0.8 1.0;
run;

proc sgplot data=pollution;
	reg x=x3 y=y / clm cli;
run;

proc loess data=pollution;
	model y=x3/smooth=0.1 0.2 0.4 0.6 0.8 1.0;
run;

proc sgplot data=pollution;
	reg x=x4 y=y;
run;

proc loess data=pollution;
	model y=x4/smooth=0.1 0.2 0.4 0.6 0.8 1.0;
run;

proc sgplot data=pollution;
	reg x=x5 y=y / clm cli;
run;

proc loess data=pollution;
	model y=x5/smooth=0.1 0.2 0.4 0.6 0.8 1.0;
run;

/* 3. specification of the model */
* box-cox analysis and transformation on y ;
proc transreg data=pollution;
	model boxcox(y)=identity(x1 x2 x3 x4 x5);
run;

data trans1;
	set pollution;
	y_trans1=y**2;
run;

/* 4. estimation of the appropriate model */
proc reg data=trans1 plots(label)=(cooksd RESIDUALBYPREDICTED RSTUDENTBYLEVERAGE 
	RSTUDENTBYPREDICTED dfbetas dffits diagnostics observedbypredicted);
	model y_trans1=x1-x5/	alpha=.05 r p clb cli clm stb vif partial influence collinoint collin;
	output out=one r=resid student=sresid p=pred rstudent=rs r=y_res;
	run;
proc univariate data=one plot normal;
	var rs; * qqplot r-student residual vs predicted ;
run;


/* 5. assessment of the chosen prediction equation */
* delete an outlier ;
data pollution_new;
	set trans1 end=last;
	if not last then
		output;
run;

* refit the model ;
proc reg data=pollution_new plots(label)=(cooksd RSTUDENTBYPREDICTED dfbetas dffits diagnostics 
		observedbypredicted);
	model y_trans1=x1 x2 x3 x4 x5/alpha=.05 r p clb cli clm stb vif partial 
		influence collinoint collin;
	output out=one r=resid student=sresid p=pred rstudent=rs r=y_res;
	run;

proc univariate normal plot data=one;
	var rs; * qqplot r-student vs predicted ;
run;

* box-cox analysis and transformation on y ;
proc transreg data=pollution_no_outlier;
	model boxcox(y)=identity(x1 x2 x3 x4 x5);
run;

data trans2;
	set pollution_no_outlier;
	y_trans2=y**1.5;
run;

* refit the model ;
proc reg data=trans2 plots(label)=(cooksd dfbetas dffits RSTUDENTBYPREDICTED diagnostics observedbypredicted);
	model y_trans2=x1 x2 x3 x4 x5/alpha=.05 r p clb cli clm stb vif partial 
		influence collinoint collin;
	output out=one r=resid student=sresid p=pred rstudent=rs r=y_res;
	run;

proc univariate normal plot data=one; 
	var rs; * qqplot r-student vs predicted ;
run;

/* weighted ls est */
* step0: initial step ;
proc reg data=pollution;
	model y=x1 x2 x3 x4 x5 / clb;
	output out=result1 p=yhat r=resid;
	run;
	
* step1: estimate standard dev. function ;
data result1;
	set result1;
	absres=abs(resid);
run;

proc reg data=result1;
	model absres=x1 x2 x3 x4 x5;
	output out=step1 p=preds1 r=ress;
	run;

data step1;
	set step1;
	wt1=1/(preds1)**2;
run;

proc reg data=step1;
	model y=x1 x2 x3 x4 x5 /p clb;
	weight wt1;
	output out=result2 p=wyhat r=wres;
	run;
	
* step2: estimate the standard dev. function ;
data result2;
	set result2;
	abswres=abs(wres);
run;

proc reg data=result2;
	model abswres=x1 x2 x3 x4 x5;
	output out=step2 p=preds2;
	run;

data step2;
	set step2;
	wt2=1/(preds2)**2;
run;

proc reg data=step2 plots(label)=(RSTUDENTBYPREDICTED);
	model y=x1 x3 x4 x5 /p r clb cli clm stb vif partial collinoint collin;
	weight wt2;
	output out=one r=resid student=sresid p=pred rstudent=rs r=y_res;
	run;
proc univariate data=one plot normal;
	var rs; * qqplot r-student residual vs predicted ;
run;

/* 6. variable selection */
* forward selection ;
proc reg data=step2;
	model y=x1 x2 x3 x4 x5 / selection=forward slentry=0.25;
	weight wt2;
	run;
	
* backward selection ;
proc reg data=step2;
	model y=x1 x2 x3 x4 x5 / selection=backward slstay=0.1;
	weight wt2;
	run;
	
* stepwise selection ;
proc reg data=step2;
	model y=x1 x2 x3 x4 x5 / selection=stepwise slentry=0.15 slstay=0.15;
	weight wt2;
	run;
	
* all possible selection ;
proc reg data=step2;
	model y=x1 x2 x3 x4 x5 / selection=cp rsquare mse adjrsq p clm cli best=10;
	weight wt2;
	run;
	
	
	
	
	
	

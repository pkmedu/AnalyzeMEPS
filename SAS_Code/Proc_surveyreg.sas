
proc format;
value cancerdx_fmt
      -9,-8,-7, -1 =.
      1 = 'YES'
      2 = 'NO';
run;
proc SURVEYREG DATA = pufmeps.h201;
STRATUM VARSTR;
CLUSTER VARPSU;
WEIGHT PERWT17F;
DOMAIN  sex;
CLASS cancerdx(ref='NO');
MODEL totexp17 =cancerdx/ solution clparm;
format cancerdx cancerdx_fmt.;
run;

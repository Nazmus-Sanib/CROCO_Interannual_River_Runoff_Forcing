%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DEVELOPED by Md Nazmus Sanib Chowdhury on September 16, 2026.
%
%  You are free to redistribute it and/or modify it under the terms of
%  the GNU General Public License as published by the Free Software 
%  Foundation.
%
%  
%  This code was developed to automate the process of generating the
%  runoff forcing files for an interannual simulation using the
%  "croco_clm_mercator_Y????M??.nc" files whose are located in the
%  user's croco_project_directory/CROCO_FILES. This file has to be 
%  run after running the start.m from the user's 
%  croco_project_directory/croco_tools/start.m through a MATLAB 
%  editor. Then runoff files aligning the years and months 
%  corresponded to the "croco_clm_mercator_Y????M??.nc" files
%  will be created in the croco_project_directory/CROCO_FILES
%  directory. It is worthwhile to note in here that, during the
%  generation of runoff files, though the tracers of the river mouths
%  are taken from the "croco_clm_mercator_Y????M??.nc" files, the
%  river discharge are taken from the Dai and Trenberth Global River 
%  Flow and Continental Discharge Dataset (Dai and Trenberth runoff). 
%  Nevertheless, Dai and Trenberth runoff can be replaced by the by a
%  user defined river discharge data (e.g., in-situ data) sharing the
%  same data structure, format and location (i.e., 
%  croco_tools/RUNOFF_DAI) of the Dai and Trenberth runoff data while, 
%  user need to provide the name of the new runoff data assigning it 
%  as the second value of the "global_clim_rivername" list-type 
%  variable in the 
%  croco_project_directory/croco_tools/crocotools_param.m file. In
%  addition, this file (i.e., automate_make_runoff.m) generate 
%  psource_LSRC_TSRC_????.csv files, while "????" are replaced by the
%  corresponding years. These *.csv files containing the LSRC and TSRC
%  whose are referred to the yearly mean temperature and yearly mean
%  salinity for the selected rivers respectively. The usage of this 
%  file is mentioned as follows: 
%
%  At first place and/or replace the argument_def_dir.m, make_runoff.m,
%  automate_make_runoff.m and runoff_glob_extract.m files in the
%  CROCO_TOOLS/rivers directory. Here, CROCO_TOOLS referred to the 
%  source CROCO_TOOLS you downloaded and unzipped or extracted from the
%  official download section of the CROCO website. 
%  
%  Then, In a MATLAB editor from the croco_tools of your project directory
%  run the following:
%  start
%  automate_make_runoff
%
%  Then, the MATLAB editor will ask you start year, end year, start month
%  and end month respectively. You will need ton provide them one by one.
%  For example, insert
%  2026
%  2026
%  1
%  3
%
%  Here, 2026, 2026, 1 and 3 are start year, end year, start month (January),
%  and end month (March) respectively.
%  
%  Then you will be required to set the selection of rivers and the
%  orientation of the corresponding rivers you used to set during running a
%  make_runoff.m file for generating a river runoff file for a climatological 
%  simulation. You will require to do such a process of selection for only
%  once. For the other months, the data for such selection will automatically 
%  be passed as the argument of the river_runoff function from the return of 
%  the calling of the preceding river_runoff function.
%
%  Then, collect the TSRC and LSRC for each year from each 
%  your_croco_project_directory/croco_tools/psource_LSRC_TSRC_????.csv files.
%  Then, collect the number of rivers from the status mentioned after the:
% 
%  psource_ncfile:   Nsrc  Isrc  Jsrc  Dsrc qbardir  Lsrc  Tsrc   runoff file name
%                           croco_runoff.nc
%                   {number of rivers}
%
%  Using the LSRC, TSRC (from a 
%  your_croco_project_directory/croco_tools/psource_LSRC_TSRC_????.csv file for
%  a year) and number of rivers populate the section:
%  "psource_ncfile:   Nsrc  Isrc  Jsrc  Dsrc qbardir  Lsrc  Tsrc   runoff file name
%                           croco_runoff.nc"
%  in the your_project_directory/croco_inter.in file.
%  
%  Please note that, you have to stop the simulation after December and restart 
%  the simulation using the restart file of the December of the corresponding 
%  year, while the restarted simulation will be run for the next year. In each
%  year, repeat the populating of the 
%  "psource_ncfile:   Nsrc  Isrc  Jsrc  Dsrc qbardir  Lsrc  Tsrc   runoff file name
%                           croco_runoff.nc"
%  paragraph in the your_project_directory/croco_inter.in by replacing the same
%  paragraph from the previous year taken the LSRC and TSRC from the corresponding 
%  your_croco_project_directory/croco_tools/psource_LSRC_TSRC_????.csv file for 
%  the new year.
%
%  Then, in the your_croco_project_directory/run_croco_inter.bash
% 
%  1. Replace the RUNOFF_FILES=0 with the RUNOFF_FILES=1
%
%  2. Replace the:
%     echo "Getting ${RNFFILE}.nc${ENDF} from $MSSDIR"
%     $LN -sf $MSSDIR/${RNFFILE}.nc${ENDF} ${RNFFILE}.nc${ENDF}
%   
%     with the:
%     echo "Getting ${RNFFILE}_${RUNOFF}_${TIME}.nc${ENDF} from $MSSDIR"
%     $LN -sf $MSSDIR/${RNFFILE}_${RUNOFF}_${TIME}.nc${ENDF} ${RNFFILE}.nc${ENDF}
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clear all
close all

start_year = input(['Specify start year: ',]);
end_year = input(['Specify end year: ',]);
start_month = input(['Specify start month: ',]);
end_month = input(['Specify end month: ',]);

months_ = ['01';'02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '10'; '11'; '12'];
monthsSS = months_(start_month:end_month,:);
lenmonth = end_month-start_month+1;


lenyear = end_year-start_year+1;


input_def_dir = 0;
river_orientation = NaN;
input_indomain_last = NaN;

YEAR = start_year;
MONTH = monthsSS(1,:);


[out_river_ori, output_indomain_last,Lsrc_,Tsrc_,number_of_river] = make_runoff(input_def_dir, river_orientation, input_indomain_last,YEAR,MONTH);



LSRC = zeros(lenyear,lenmonth,number_of_river);
TSRC = zeros(lenyear,lenmonth,number_of_river);

input_def_dir = 3;


for ykyk=1:lenyear
    for mkmk=1:lenmonth
        
        river_orientation = out_river_ori;
        input_indomain_last = output_indomain_last;
        
        YEAR = start_year+ykyk-1;
        MONTH = monthsSS(mkmk,:);
        
        
        [out_river_ori, output_indomain_last,Lsrc_,Tsrc_,number_of_river] = make_runoff(input_def_dir, river_orientation, input_indomain_last,YEAR,MONTH);

        LSRC(ykyk,mkmk,:) = Lsrc_;
        TSRC(ykyk,mkmk,:) = Tsrc_;
        strSS_ = sprintf('****************** End of making runoff Year: %d and Month: %s *******************',YEAR,MONTH);
        disp(strSS_)
    end
    fname = sprintf('psource_LSRC_TSRC_%d.csv',YEAR)
    fileID = fopen(fname, 'w');
    
    fprintf(fileID,'LSRC TSRC\n');
    for nr = 1:number_of_river
        LSRCm = mean(LSRC(ykyk,:,nr));
        TSRCm = mean(TSRC(ykyk,:,nr));
        if LSRCm ~= 0
        fprintf(fileID, '%.4f %.4f\n', LSRCm, TSRCm);
        end
        
    end
    fclose(fileID);
end


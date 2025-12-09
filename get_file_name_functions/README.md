# Amazon-Scatterometry/get_file_name_functions
Retrieve file names for a specified instrument for an interval of time within one year. 
They are written with the assumption that you are pulling from the MERS scatterometer data archives. Generally, the functions work as follows:
    [file_names] = get_*sensor*_file_names(year,start_date,end_date)
If the function is not specified as CETB, then a region will need to be specified. Each sensor has different parameters included in file names that will be reflected by their respective function. Note that CETB files will be in the .nc file format, whereas all others will be .sir files. Different tools are needed to retrieve the information from these files.

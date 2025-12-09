# Amazon-Scatterometry
Processing code for Master's Thesis: "Evaluating C-Band Scatterometer Images for Estimating Deforestation in the Amazon Rainforest"

GIS data sources include: 
    prodes_all - deforestation area of all causes identified by PRODES, available from 2008-92 - 2024-240
    prodes_def - deforestation area strictly from vegetation supression identified by PRODES
    prodes_small deforestation area *smaller than typically denoted in PRODES?*
    deter - deforestation area identified by DETER, available from 2016-39 - 2025-143

Scatterometer data sources include:
    ERS-1 - ESCAT sensor on ERS-1 satellite, processed into sir format in .nc container, available from 1991-213 - 1996-154, 6.25 km resolution
    ERS-2 - ESCAT sensor on ERS-2 satellite, processed into sir format in .nc container, available from 1996-86 - 2011-185, 6.25 km resolution
    ASCAT SAm - ASCAT sensor on METOP-A satellites, processed into .sir format and divided into regions, available from 2007-1 - 2024-240, 6.25 km resolution
    ASCAT CETB - ASCAT sensor on METOP-A satellites, processed into sir format in .nc container, available from 2007-1 - 2024-366, 3.125 km resolution
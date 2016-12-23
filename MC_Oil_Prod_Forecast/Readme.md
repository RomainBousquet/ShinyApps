# Readme

## How to use this Application

The easiest way to try the application is to run it on my shiny server: http://steffenrueferapps.com/shiny/MC_Oil_Prod_Forecast/

This application can be used to get a better understanding about the single well production distribution. The Beta distribution is used as underlying model, and its input parameters can be changed. The created input distribution is then used together with other inputs to forecast the daily production output of the entire oilfield.

The application is designed to be run as Shiny Web Application - you can either run it on your own Shiny Server, or you can open it in R-Studio and run it as Shiny App.

## Input Parameters

The input parameters are used to create the production forecast.

- Number of wells: 10 - 100
- Well Production Range: 0 - 2,000 BOPD for a single well
- Shape Parameters: to change the shape of the beta distribution

To create a new or updated forecast, click on the `CREATE FORECAST` button.

## Field Model

The field model, here represented as a beta distribution, is one of the inputs for the Monte Carlo simulation. It tries to approximate the number of wells that have a certain production range.

A beta distribution with shape parameters 1 and 2 being 2 and 5, respectively, will create a field model where the majority of the wells produce a low amount of oil, while there are only very few high production wells.

This model could represent an old oilfield, where most wells are old and produce only small amounts of oil, with a few newly drilled wells that still have a high production rate.

The other parameter used in the field model is the number of wells in the field.

## Production Forecast

The production forecast is calculated through Monte Carlo simulation, by sampling from the input distribution. As many samples as wells are taken, and the sampling process is done 5,000 times.

The results of the Monte Carlo simulation are presented in three outputs:

- Production Distribution Plot/Histogram
- Cumulative Distribution Function Plot
- Data Table of 5% quantiles

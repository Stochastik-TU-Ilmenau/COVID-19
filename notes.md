### Notes

- We estimate the **reproduction number** *R(t)* at day *t*, i.e. the average number of people someone infected at time *t* would infect if conditions remained the same.
- The estimator has been taken from [(Fraser 2007)](#ref1). It compares the number of infections at a time point with the number of infectious cases at that time, weighted by their respective infectivity.
- For this estimator, we derived (approximate, pointwise) **95% confidence intervals** using the delta method.
- However, the size of the confidence intervals reflects only those statistical uncertainties due to the random dynamics of the epidemic. But since the estimator is based on assumptions about the infectivity of the virus, and given that the data are not perfect because of a change of reporting criteria, the amount of testing etc., the estimates should be cautiously interpreted and not be taken at face value. Still, we believe that one can draw qualitatively credible conclusions from them.
- Estimates are shown in black, confidence intervals as grey stripes, with values specified by the left axis (on a log-scale).
- The **critical value** for the reproduction number is 1, shown as a red horizontal line: a value larger than one would result in an exponential increase of infections, a value smaller than one in a decrease.
- The analysis is based on **newly reported cases** of Coronavirus Disease 2019 (COVID-19) per day, shown as blue bars as specified by the right axis (on a linear scale). For these we rely on the data provided by [Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19).
- For the estimated reproduction number (lines, left vertical axis), the horizontal axis specifies the corresponding date of infection whereas for the newly reported cases (bars, right axis), it specifies the date the cases were reported.
- The graphics are updated daily (last update: !NOW! GMT), showing data up to yesterday.
- Note that cases are reported much later than the corresponding day of infection, namely after incubation time plus some more days necessary for testing and reporting the case to the authorities. For simplicity we assume that cases are reported 7 days after infection. Therefore, estimates for the reproduction number lag one week behind the reporting of new cases.
- In a population where no countermeasures have been put into place, the reproduction number is believed to be given by some value between 2.4 and 3.3. Estimates higher than that might be explained by a considerable number of imported cases before the day being considered.
-  Details may be found in the accompanying [Technical Report](); the code is available [here](https://github.com/Stochastik-TU-Ilmenau/COVID-19/blob/gh-pages/estimator.r).

### References

<a name="ref1">[1]</a>: Fraser, C. (2007). *Estimating Individual and Household Reproduction Numbers in an Emerging Epidemic.* PLOS ONE 2 (8), [https://doi.org/10.1371/journal.pone.0000758](https://doi.org/10.1371/journal.pone.0000758).


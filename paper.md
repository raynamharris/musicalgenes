---
title: 'Musical Genes: Visualize and sonifiy gene expression in parenting pigeons'
tags:
  - R
  - transcriptomics
  - neuroscience
  - animal behavior
  - parental care
  - data sonification
authors:
  - name: Rayna Harris and many others
    affiliation: 1
  - name: Rebecca Calisi 
    affiliation: 1
affiliations:
 - name: UC Davis
   index: 1 
date: 15 Nov 2020
bibliography: paper.bib

# see https://joss.readthedocs.io/en/latest/submitting.html#example-paper-and-bibliography

---

##  Summary


![screenshot](www/screenshot.png)

## Statement of need

120 words max

##  Introduction 

Temporal and spatially controlled changes in gene expression are often described as a “symphony of gene expression”, with RNA polymerase function as the transcription factor that turns genes on in a coordinated fashion in response to external or internal cures. Could we gain more biological insight and make data more accessible if we utilized data sonification to actually listen to the metaphorical transitional symphony?   
  
Neuroscientists are known for listening to outputs while doing research, molecular biologists rarely use souned as a medium for data analysis or science communication. Sound has previously been used to evaluate the position of their electrodes inside cells and make inferences about the data (cite). Sonification is the use of non-speech audio to convey information or perceptualize data. Yet molecular biology continues to rely heavily on the presentation of data as technicolor images, often with complex images, illegible symbols and font, and color-blind insensitive palettes. Data sonification in transcriptomics represents a potential avenue for making transcriptomics research more accessible to broader audiences. Discuss electrophysiology in pop-culture.https://www.rollingstone.com/music/music-latin/residente-pecador-video-watch-905453/  
  
Because genes are highly conserved across species, the data from studies on model organisms are potentially useful to other scientists and clinicians. However, data accessibility is often a barrier to data reuse and thus the potential for biomedical discovery is diminished. Easy-to-use interfaces that allow users to interactively explore data in the cloud would speed discovery by eliminating the need to download data and install software as a precursor to data exploration. Sharing data and code alone, but using these notebook requires technical knowledge that many researchers and clinicians do not have. A challenge that researchers face is designing sequencing projects need to be large enough to have sufficient power to test hypotheses, and then making the data and results easily accessible to reduce barriers to translation research.   
  
We sought to create an open source tools for data exploration that could be used to reproducibly convert gene expression into sound. As a proto-type, we used data from Harris, Austin, et al 2020, a highly replicated experimental design to characterize the transcriptional activity of the hypothalamus, pituitary, and gonads axis at nine time points over the course of reproduction and parental care in male and female pairs as they transitioned from a sexually mature, non-reproductive state to a reproductive one. Nine pseudo-timepoints measured represent nest building, egg incubation, nesting care, and fledging (Fig 1).   
  
## Materials and Methods  
  
Gene expression data associated with Harris, Austin, et al 2020 (https://github.com/macmanes-lab/DoveParentsRNAseq) were imported into R for processing, analysis, and visualization (cite all the r packages).   
  
We used the Hugo database to match gene symbols with gene names for users who are less familiar with gene acronyms. STILL NEED TO DO STRING PASTE  
  
We used R shiny to build a web application with the dual ability to reproduce a figure from the associated manuscript and sonify the data (https://raynamharris.shinyapps.io/musicalgenes/).   
  
As in Harris, Austin et al 2020, we show box-and-whisker plot median and range of gene expression at difference stages of reproduction, from building nests and incubating eggs to nurturing baby chicks. Stars above denote statistically significant chagnes in gene expression between sequential timepoints. The user of the shiny app can explore the expression pattern of 140 genes, whereas the reader of the associated primary literature can only explore 6.   
  
Additionally, we calculated the mean value of gene expression for each group and sonified those values using the R packages `sonify` and `tuneR` (ref). We also scaled and rounded the data to an integer from 0-6 and then converted those numbers A, B, C, D, E, F, or G so that the user can play a representation of the data on an instrument on their choosing, such as a piano (Supplementary Figure 1). A created a video tutorial desripbing how to use the Shiny app (Supplementary FIle 2).     
  
All the R code available under CC-BY at https://github.com/raynamharris/musicalgenes.    
  
The default gene expression pattern shown by the shiny app is that of the prolactin gene (aslso refereed to as PRL) in the female pituitary, which has a musical pattern of CABBBCBCFEFGFFED (FIg. 2). Prolactin increases significantly between incubation day 9 and incubation day 17. Prolactin decrease significantly between non-reproductive control and nest building stages as well as between hatch and nestling care day 5. When offspring are removed at X, Prolactin decreases significantly when you remove offspring at incubation days 9, 17, and at hatch as well as when you extend the timing until hatch.   
  
By simultaneously viewing the data, reading the statistical summary, and listening the the changes in mean expression, the user gains a deeper understand at the complexity of the variation in the data. The farther away the notes are on the scale, the greater the difference in expression. Smale changes in expression, as indicated by adjunct notes (e.g.  F to G or E to D) are typically not significant, but large changes (e.g A to D or G to D) often represent significant increases or decreases in expression over time.   

## Results and Discussion  (3000 max)
  
We have created an Rstudio cloud enviornment that can sonify (turn into sound) the mean value of any given candidate gene and play it on the piano as a song as well as present resreent the data with statictics snd graphs as is typical of a scientific manuscript.   
  
By providing the combination of a statistical summary, a visual representation, and a musical resprenstation of the data, one can look for both broad and specific patterns in the data. For instance, the results above for prolactin illustrate beautifully how some genes increase their expression in preparation for a biological even then fall once that even has past or if its timing is altered. This makes sense given what we know about prolactin… Should I say something about how co-authors of this paper are biased towards prolactin?? Like think these results to what we have written about its role in reproduction and parental care before ( as in Oldfield, Harris, et al 2013; Austin and Word). Or say that Fararr et al in prep focuses solely on pituitary PRL in the hypothalamus and the gonas of male and females?   
  
By creating an interactively webapplication, we facilitate the generation and exploration of the data and results for dozens of genes of interest. The avilablility of this dataset will be of use to researchers trying to understand the role of candidate genes in regulating the fascinating biological transition into parenthood or the terrifying clinical transition into cancer. We turned gene expression data into music to make it posssible to listen to transcriptional changes that are of interest to scientists and clinicians.  
  
As stated in the introduction, we would like to bring to life the transcriptional symphony of parental care, but currently the tool Musical Genes only plays the sound of one gene at a time.   
In the future, we would like to play the sounds of many genes at once by a digital or live orchestra to listen to coordinated or discordiated changes in gene expression.   
  
Another limiation of this application is that is is directly tied to this particular data. A future implementation of the tools could allow flexible data input. For instance, BioJupies is an online tool that rapidly creates interactive visualization of any RNA-seq data set in NCBI or a user uploaded data set (Torre et al). Our software applies to a single data set. The complexity of our experimental design with multiple variables and many combinations of comparison, scaling the data wrangling and visualization is not feasible. Regardless of size, future studies benefit from tools like BioJupies or Musical Genes or rapid data assessment. 

Despite these limitations, we still believe that this application presents a unique contribution to science by providing open access to software that makes data and results more accessible to diverse audiences.  

![screenshot](www/screenshot2.png)

# References

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.


# Acknowledgements

We acknowledge contributions from x and y.

# References

# website-classification

The Code is separated in 3 main blocks:
1) Startup
2) Unsupervised learning: Clustering
3) Supervised learning: Models for Classification

1) Startup
When using R-Studio, this script will set up your working directory to the root path of the folder.
It will also insall all required packages. Please note, that some will require user interaction in the terminal.


We provide a list of domainnames and a class-label. Using a simple crawler like Rcrawler the html content of these pages can be downloaded. For our work we crawled up to 30 pages within the website.
Afterwards the plain text has to be parsed from the html, removing all html-tags.
The result should ba a table with two columns: The domainname (as the key) and the column (named "volltext") with the plain text of all the crawled pages of the website concatenated (both string). Of course, the class-label can also be kept.
With this data you can proceed to the unsupervised learning.

domain|volltext|category
-------------------------
web.de| pagetext| K



2) Unsupervised Learning

The usupervised learning starts with loading the data you created the way described above.
At the beginning, the texts are transformed into document-term-matrices. Don't wonder about test and training, they are the same. Function was implemented with supervised learning in mind.

You find code and evaluation of the clusting using k-means and DIANA.
there is also a visualization of them using t-sne which gives an overview, how good they worked.



3) Supervised learning.
The supervised learning contains many models and parameter sets. therefore training and evaluation are moved into functions. A wrapper function reads in an excel-file, the execution-list.
It contains the name of the model and the parameters to set for training & evaluation. You will have to reduce it to the for you relevant models and combinations. Otherwise computation time will  be long and errors are to be expected due to different datasets / splits.

It is important to get the shape of the input data correct.
We included the script we used for creation of different shaped training / validateion / test -Slpits. 
Unfortunately they are not generic, so you will have to adapt them to your data.
In our experiments we used the random sample as test-data, but here we will just make validationdata = testdata. You can change this if required and make other splits.
As the qualityset will be hard to reproduce we took it from the script.

These ar in the scripts:

function_load_and_split.R: master$loadAndSplit() 
  Will take a path to an rds-file with your data (as described above) as input. You can easily change it to read from the environment or save your collected data as datatable in an rds-file.
  
function_prepare_dtm.R: master$prepDTMs()
  Takes the output of  master$loadAndSplit() as input and creates the trainingdata for all different experiments.
  
  
  After loading the training data, you decide, which models you want to execute / train & test.
  The results are saved to disk for later analysis. They contain the evaluation, confusion-matrices etc. So you can evaluate them completely.
  
  
  
  
  
#data directory is expected within the work directory

#work directory variable
#wkdir <- "/Users/yizhuoma/Desktop/312/"
wkdir <- "~/cphg/pTyrSignalComparison/"

#How Many Gels?
gelcount=8

#create results folder
dir.create(file.path(wkdir, "results"), showWarnings = FALSE)

#read in data
ptyr <- read.csv(paste0(wkdir,"data/barcode.csv"),header=TRUE)

#Make changes to master table
ptyr$Family_ID <- as.character(ptyr$Family_ID)
ptyr$Analytic_ID <- as.character(ptyr$Analytic_ID)
#ptyr <- ptyr[ptyr$Status!='Total',]
#ptyr$Status <-factor(ptyr$Status)
statuslist <- unique(ptyr$Status)

#statuslist<- statuslist[statuslist != "Total"]



titleprefixes <-c("Int_n_Bk_n_A","Int_n_Bk", "Int_n_A_n_Bk")
blank.frame <-data.frame(Int_n_Bk_n_A = numeric(), Int_n_Bk = numeric(), Int_n_A_n_Bk= numeric(), 
                         Sample.ID = numeric(), Family_ID = character(), Analytic_ID = character(),
                         Status=character(), Gel = numeric())
non_intensity_cols <- c("Sample.ID", "Family_ID","Analytic_ID","Status")

#Rearrange Table into desired form

whole.frame <- blank.frame

for (status in statuslist){
  
  #Add a gel number column while munging the table
  for (i in seq(1,gelcount)){
    gel.frame <- ptyr[ptyr$Status==status,c(paste0(titleprefixes,".G",i),non_intensity_cols)]
    gel.frame$Gel <- i
    colnames(gel.frame) <- colnames(whole.frame)
    whole.frame <-rbind(whole.frame,gel.frame)
  }
}
  #create a vector to indicate pch values during graphing based on Family ID
  pch.list <- rep(0, length(whole.frame$Family_ID))
  pchselection <- c(0:length(whole.frame$Family_ID))
  pch.list <- pchselection[as.numeric(as.factor(whole.frame$Family_ID))]

#Boxplot graphs PER STATUS
for (status in statuslist){
  status.frame <- whole.frame[whole.frame$Status==status,]
  for (i in seq(1,3)){
    titleprefix <- titleprefixes[i]
    pdf(paste0(wkdir,"results/pTyrSignalling_Boxplots_",status,titleprefix,".pdf"),
        width=11,height=8, title=paste("pTyr Signalling -",status,titleprefix))
    
    plot(log(status.frame[,c(titleprefix)],base=2) ~ as.factor(status.frame$Sample.ID),
         ylab=paste("log2(Normalized Intensity)",titleprefix), xlab="Sample ID",main=paste("pTyr Signalling -",status))
    points(log(status.frame[,titleprefix],base=2) ~ as.factor(status.frame$Sample.ID),
           col=status.frame$Gel,pch=pch.list)
    legend('topright',c(paste("Gel",c(unique(status.frame$Gel))),unique(status.frame$Family_ID)),
           col=c(unique(status.frame$Gel),rep("black",times=gelcount)),
           cex=.7,pch=c(rep(19,times=gelcount),unique(pch.list)),ncol=2)
  dev.off()
  }
}


#Boxplot graphs PER SAMPLE
samplelist <- unique(whole.frame$Sample.ID)
for (sample in samplelist){
  #sample.frame <- whole.frame[whole.frame$Sample.ID==sample,]
  for (i in seq(1,3)){
    titleprefix <- titleprefixes[i]
    
    pdf(paste0(wkdir,"results/pTyrSignalling_Boxplots_Sample",sample,"_",titleprefix,".pdf"),
        width=11,height=8, title=paste("pTyr Signalling - Sample",sample,titleprefix))
    subplot <- whole.frame[whole.frame$Sample.ID==sample,c(titleprefix,"Sample.ID","Status","Gel")]
    #plot(log(sample.frame[,c(titleprefix)],base=2) ~ as.factor(sample.frame$Status),
    plot(log(whole.frame[whole.frame$Sample.ID==sample,c(titleprefix)],base=2) ~ 
           as.factor(whole.frame[whole.frame$Sample.ID==sample,]$Status),
         ylab=paste("log2(Normalized Intensity)",titleprefix), xlab="Status",
         main=paste("pTyr Signalling - Sample",sample))
    #points(log(sample.frame[,c(titleprefix)],base=2) ~ as.factor(sample.frame$Status),col=sample.frame$Gel)
    points(log(whole.frame[whole.frame$Sample.ID==sample,c(titleprefix)],base=2) ~ 
             as.factor(whole.frame[whole.frame$Sample.ID==sample,]$Status),
           col=whole.frame[whole.frame$Sample.ID==sample,]$Gel)
    #legend('topright',paste("Gel",c(unique(sample.frame$Gel))),col=unique(sample.frame$Gel),pch=1,cex=.7)
    legend('topright',paste("Gel",c(unique(whole.frame[whole.frame$Sample.ID==sample,]$Gel))),col=unique(whole.frame[whole.frame$Sample.ID==sample,]$Gel),pch=1,cex=.7)
    dev.off()
  }
}



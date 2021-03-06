#Simulating LI data to check on correlation patterns
#Started DVM Bishop, 25th October 2017


library(Hmisc) #for correlations


##########################################################################
#check how many combinations of possible tasks 
#(This is separate from rest of script -just to confirm how many possibilities)
x=1:6  #N tasks
m=3  #N tasks that each person does
combn(x, m, FUN = NULL) #To see all combinations
##########################################################################

myN<-20 #specify N subjects for each sample
bigN<-10000 #specify size of population to sample from

##########################################################################
#Generate bigN random normal deviates :these simulate frontal and for posterior bias
#These corresponding to the underlying, unmeasured laterality bias for bigN people in the population
#Usually we'd have mean 0 and SD 1, but I've specified mean 1 and SD 1 for both posterior and frontal, 
#to reflect population bias to L
#This won't affect correlations but may be useful later on if we want to simulate means for different tasks
#Or if we want to simulate situation with different degrees of bias.


frontL<-rnorm(bigN,1,1) #laterality distribution frontal
postL<-rnorm(bigN,1,1) #laterality distribution posterior - independent in this case from frontL
##########################################################################

#Each task now specified as a weighted sum of frontL, postL, and error term.

#First, create blank dataframe with NAs to hold simulated data for bigN cases
alltask<-data.frame(matrix(rep(NA,bigN*12),nrow=bigN) )
mylabel=c('A1','B1','C1','D1','E1','F1','A2','B2','C2','D2','E2','F2')
colnames(alltask)<-mylabel

#Next specify the weightings and error for each task - can change these.
#We will assume we have 2 tasks predominantly frontal, 2 predom posterior and 2 equal
#For each type of task, one has a bigger error term and one smaller
#NB all these options can be altered.

#mywts has one col per task; row 1 is front wt, row 2 is post wt, row 3 is error
#these are set to sum to one.

mywts<-matrix(c(.7,.7,.35,.35,0,0,
                0,.0,.35,.35,.7,.7,
                .3,.3,.3,.3,.3,.3),byrow=TRUE,nrow=3)

#We now use these weights to simulate data for 2 runs with each task
thiscol<-0 #zero the counter for columns
for (j in 1:2){
for (i in 1:6){
 thiscol<-thiscol+1 #increment to next column
 alltask[,thiscol]<-mywts[1,i]*frontL+mywts[2,i]*postL+mywts[3,i]*rnorm(bigN,0,1)
}
}

nrun<-1000 #N runs of simulation
#create dataframe to hold all the correlations, so we can see how variable from run to run
allr<-data.frame(matrix(rep(NA,nrun*66),nrow=nrun) )
colnames(allr)<-c('A1.B1','A1.C1','A1.D1','A1.E1','A1.F1',
                  'A1.A2','A1.B2','A1.C2','A1.D2','A1.E2','A1.F2',
                  'B1.C1','B1.D1','B1.E1','B1.F1',
                  'B1.A2','B1.B2','B1.C2','B1.D2','B1.E2','B1.F2',
                  'C1.D1','C1.E1','C1.F1',
                  'C1.A2','C1.B2','C1.C2','C1.D2','C1.E2','C1.F2',
                  'D1.E1','D1.F1',
                  'D1.A2','D1.B2','D1.C2','D1.D2','D1.E2','D1.F2',
                  'E1.F1',
                  'E1.A2','E1.B2','E1.C2','E1.D2','E1.E2','E1.F2',
                  'F1.A2','F1.B2','F1.C2','F1.D2','F1.E2','F1.F2',
                  'A2.B2','A2.C2','A2.D2','A2.E2','A2.F2',
                  'B2.C2','B2.D2','B2.E2','B2.F2',
                  'C2.D2','C2.E2','C2.F2',
                  'D2.E2','D2.F2',
                  'E2.F2')

for (j in 1:nrun)
{
#Now sample myN cases from the population
alltask.N<-alltask[sample(bigN,myN),]

#Now compute Spearman correlations between tasks within our sample
#Hmisc package has options for Spearman/Pearson. They will be v similar for normal data
#but later if we want to simulate non-normal data, we will need spearman.
mycorrs<-rcorr(as.matrix(alltask.N), type="spearman") 
mycorrs<-mycorrs$r #we just want the correlations and not the p-values that rcorr generates
mycorrs<-data.frame(mycorrs)
allr[j,]<-c(mycorrs[1,2:12],mycorrs[2,3:12],mycorrs[3,4:12],mycorrs[4,5:12],mycorrs[5,6:12],
            mycorrs[6,7:12],mycorrs[7,8:12],mycorrs[8,9:12],mycorrs[9,10:12],mycorrs[10,11:12],mycorrs[11,12])
}

#just save and plot the last one
mycorrs<-cbind(1:12,mycorrs) #add a serial set of numbers so we can plot easily
colnames(mycorrs)<-c('X',mylabel)
par( mfrow = c( 3, 2 ) )
for (i in 2:13){
  mytitle<-paste('Correl with',colnames(mycorrs[i]))
  label2<-mylabel
  thislabel<-paste0(mylabel,colnames(mycorrs[i]))
  par(las=2)
plot(mycorrs[,1],mycorrs[,i],main=mytitle,type='p',
     xlab='Task',ylab='Spearman r',cex=.1,ylim=c(0,1))
axis(1, at=1:12, labels=mylabel)

text(mycorrs[,1],mycorrs[,i],
     label=mylabel)
}


rmeans<-apply(allr,2,mean)



rm(list=ls())
load("../R_object/Glaucoma_data.RData")


attach(Gdata)
patients<-factor(Patient)
a<-table(patients)
tmp=unique(patients)
tmp_data=tmp[which(a>=6)] # consider only patients with at least 6 visits
length(tmp_data)
Gdata_6vis=Gdata[Patient %in% tmp_data,]
rm(tmp)
rm(tmp_data)
rm(patients)
detach(Gdata)
attach(Gdata_6vis)
rm(Gdata)

patients<-factor(Patient)#recompute values with new data
a<-table(patients)
numerosity<-as.integer(a)



matrix1<-cbind(Patient,RNFL_average,Rim_area)

primi2<-matrix(0,2*length(unique(Patient)),3)
ii=1;
jj=1;
iter=1;
while(iter<1057){
  primi2[jj,2]<-matrix1[iter,2]
  primi2[jj,3]<-matrix1[iter,3]
  primi2[jj,1]<-matrix1[iter,1]
  primi2[jj+1,2]<-matrix1[iter+1,2]
  primi2[jj+1,3]<-matrix1[iter+1,3]
  primi2[jj+1,1]<-matrix1[iter+1,1]
  
  iter<-iter+numerosity[ii];
  jj=2*ii+1;
  ii<-ii+1;
  
}
head(primi2)
tail (primi2)

for(i in c(1:dim(primi2)[1])) # just a test: fill NA with random values
{
  if (is.na(primi2[i,2]))
    primi2[i,2]=runif(1, min=60, max=108);
  if (is.na(primi2[i,3]))
    primi2[i,3]=runif(1, min=0.3, max=1.7);
    
    
}
primi2

################JAGGAMENTO#######################
library(rjags)


data=list(y=primi2[,2],x=primi2[,3],  npat= 102)# dati che passo a jags



inits = function() {list(beta1=0, beta2=rep(0,102), sigma=5)} # fixed intercept, random slope


modelRegress=jags.model("data1.bug",data=data,inits=inits,n.adapt=1000,n.chains=1)
update(modelRegress,n.iter=19000)
variable.names=c("beta", "sigma")
n.iter=50000 
thin=10 
outputRegress=coda.samples(model=modelRegress,variable.names=variable.names,n.iter=n.iter,thin=thin)

library(coda)
library(plotrix) 
outputRegress_mcmc <- as.mcmc(outputRegress)
x11()
plot(outputRegress_mcmc)

data.out=as.matrix(outputRegress)
data.out=data.frame(data.out)
attach(data.out)
n.chain=dim(data.out)[1] 
n.chain
summary(data.out)
head(data.out)

beta.post <- data.out[,1:2]
beta.bayes  <- apply(beta.post,2,"mean")
beta.bayes

sig.post= data.out[,'sigma']

y1=primi[,1]; x1=primi[,2];
pippo= lm(y1 ~ x1)
summary(pippo)

pippo$coefficients
beta.bayes

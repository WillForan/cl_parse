library(ggplot2)
fitlist <- read.table('2014-08-04.tsv',header=T,sep="\t")
ggplot(fitlist,aes(x=year,y=price,shape=title_status, color=transmission))+geom_point(aes(size=odometer))+geom_text(aes(label=where),hjust=0,vjust=-1)+theme_bw()

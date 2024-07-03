#######Load libraries
library(farver)
library(plyr)  
library(schemr)
library(tidyverse)
library(CircStats)
library(cowplot)
library(ggplot2)

#######Create a CIELab space of 16,5 million points
R<-c(0:255)
G<-c(0:255)
B<-c(0:255)
RGB<-expand.grid(R,G,B)
Rain<-convert_colour(RGB, from = "rgb", to = "lab")
Rain<-as.data.frame(Rain)

names(Rain)[1]<-"L"
names(Rain)[2]<-"X"
names(Rain)[3]<-"Y"

########Calculate Chroma and Hue
Rain$Chroma_R<-sqrt((Rain$X*Rain$X)+(Rain$Y*Rain$Y))

#Calculate Hue : tan-1(X/Y)
Rain$Hues_R<-atan(Rain$Y/Rain$X)

#Calulate degree angles: Hues_R*180/pi
Rain$H_R<-Rain$Hues_R*180/pi

#Calulate the right spin angles
Rain$Spin_R<-ifelse(Rain$X>=0&Rain$Y<0,abs(Rain$H_R),
                    ifelse(Rain$X<0&Rain$Y<0,90-Rain$H_R,
                           ifelse(Rain$X<0&Rain$Y>=0,abs(Rain$H_R),
                                  ifelse(Rain$X>=0&Rain$Y>=0,90-Rain$H_R,0))))

#Calculate full wheel angles
Rain$Wheel_R<-ifelse(Rain$X>=0&Rain$Y>=0,Rain$Spin_R,
                     ifelse(Rain$X>=0&Rain$Y<0,Rain$Spin_R+90,
                            ifelse(Rain$X<0&Rain$Y<0,Rain$Spin_R+180,
                                   ifelse(Rain$X<0&Rain$Y>=0,Rain$Spin_R+270,0))))

#Mirror wheel
Rain$Mirror_R<-360-Rain$Wheel_R

#Spin wheel clock-wise
Rain$Spinned_R<-Rain$Mirror_R+90
Rain$Spinned_R<-ifelse(Rain$Spinned_R>=360,Rain$Spinned_R-360,Rain$Spinned_R)

#Turn NAs into 0
is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))
Rain[is.nan(Rain)] <- 0

########Create bins
Rain$Angle<-round_any(Rain$Spinned_R, 2)  
Rain$Angle<-ifelse(Rain$Angle==360,0,Rain$Angle)

#Get maximum chromacity value for each bin
MaxC<-aggregate(Rain$Chroma_R ~ Rain$Angle, Rain, function(Rain) max(Rain))
names(MaxC)[1]<-"Angle"
names(MaxC)[2]<-"Chroma_R"

#merge the two data frames
MaxC2<-merge(MaxC,Rain[,1:4], by="Chroma_R")
Rain2<-MaxC2[order(MaxC2$Angle),]
Rain2<-data.frame(Rain2,"Freq" = 1100)

#Get Lab value for max chromaticity point of each bin
hex<-lab_to_hex(Rain2[,3:5], transformation = "sRGB", linear_func = NULL)


#########Generate random data
a<-45
b<-5
df1<-rnorm(5000, mean=22, sd=b*2)
df2<-rnorm(2000, mean=22+a, sd=b)
df3<-rnorm(1000, mean=22+(2*a), sd=b*2)
df4<-rnorm(10000, mean=22+(3*a), sd=b*1.5)
df5<-rnorm(500, mean=22+(4*a), sd=b)
df6<-rnorm(5000, mean=22+(5*a), sd=b*3)
df7<-rnorm(2500, mean=22+(6*a), sd=b*1.5)
df8<-rnorm(5000, mean=22+(7*a), sd=b*0.8)
Data<-as.data.frame(c(df1,df2,df3,df4,df5,df6,df7,df8))

names(Data)[1]<-"Hue"
Data$Hue<-ifelse(Data$Hue<=0,Data$Hue+360,Data$Hue)
Data$Angle<-round_any(Data$Hue, 2) 
Pivot<-as.data.frame(table(Data$Angle))
names(Pivot)[1]<-"Angle"

###########Create plot

#Make Color wheel plot
p <- ggplot(Rain2, aes(x=as.factor(Angle), y=Freq/6,width=1)) +
  geom_bar(stat="identity", fill=hex) +
  ylim(0,500) +
  theme_minimal() +
  theme(axis.text = element_blank(),axis.title = element_blank(),panel.grid = element_blank(),plot.margin = unit(rep(-2,4), "cm")) +
  coord_polar(start = 0)
#p

#Make data histogram plot
q<-ggplot(Pivot, aes(x=as.factor(Angle), y=Freq)) +
  geom_bar(stat="identity", fill="black", width=1.2)+
  coord_polar(theta = "x", start = 1, direction = 1) +
  theme_void()+
  scale_y_continuous(
    limits = c(-500, 1100),
    expand = c(0, 0))
#q

#Overlay both plots
inset <- p
ggdraw(q) +
  draw_plot(inset, .247, .247, .5, .5)+
  theme_void()









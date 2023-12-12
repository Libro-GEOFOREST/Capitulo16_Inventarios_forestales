Admon.pto<-read.csv("E:/MOOC_BBDD/ADMON_PUNTO.csv")
Arbol.base<-read.csv("E:/MOOC_BBDD/ARBOL_BASE.csv")
Evalua.arbol<-read.csv("E:/MOOC_BBDD/EVALUA_ARBOL.csv")

#Nombre de las columnas de la tabla general de administración del punto
names(Admon.pto)

#Cambiar nombre al primer campo
names(Admon.pto)[1]<-"X"

#Comprobación del cambio de nombre
names(Admon.pto)

#Nombre de las columnas de la tabla general de administración del punto
names(Arbol.base)

#Cambiar nombre al primer campo
names(Arbol.base)[1]<-"ID_ARBOL"

#Comprobación del cambio de nombre
names(Arbol.base)

#Nombre de las columnas de la tabla general de administración del punto
names(Evalua.arbol)

#Cambiar nombre al primer campo
names(Evalua.arbol)[1]<-"ID_ARBOL"

#Comprobación del cambio de nombre
names(Evalua.arbol)

#Códigos de monte introducidos en la capa
levels(as.factor(Admon.pto$COD_MN))

#Número de puntos muestreados con código similar al del monte
length(grep("^MA-30037",Admon.pto$COD_MNT))

#Activación de la librería necesaria
library(sf)

#Transformación de la tabla en un shapefile 
Admon.pto.sp <- st_as_sf(x=Admon.pto,coords=c("X","Y"), crs=32630)

#Proyección de la capa del monte al mismo crs que los puntos
Pinar.Yunquera<-st_transform(Pinar.Yunquera,
                             crs=st_crs(Admon.pto.sp))

#Eliminación de datos en la coordenada z
Pinar.Yunquera<-st_zm(Pinar.Yunquera,drop=TRUE)

#Representación de ambas capas
library(mapview)

mapview(Admon.pto.sp,zcol="PUNTO")+(Pinar.Yunquera)

#Selección geográfica de los puntos 
Ptos.sp.monte<-Admon.pto.sp[which(st_within(Admon.pto.sp,
                                            st_geometry(Pinar.Yunquera),
                                            sparse=FALSE)==TRUE),]

#Códigos de monte en la capa 
levels(as.factor(Ptos.sp.monte$COD_MN))

#Localización de los puntos según su código de monte
mapview(Ptos.sp.monte,zcol="COD_MNT")+(Pinar.Yunquera)

#Corrección de códigos de monte 
Ptos.sp.monte$COD_MN<-"MA-30037-AY"

#Comprobación
levels(as.factor(Ptos.sp.monte$COD_MN))

#Número de filas de la tabla
nrow(Ptos.sp.monte)

#Número de filas de la tabla con los valores duplicados eliminados
nrow(unique(Ptos.sp.monte))

#Número de filas de la tabla
nrow(Arbol.base)

#Número de filas de la tabla con los valores duplicados eliminados
nrow(unique(Arbol.base))

#Número de filas de la tabla
nrow(Evalua.arbol)

#Número de filas de la tabla con los valores duplicados eliminados
nrow(unique(Evalua.arbol))

#Unir tablas Ptos.sp.monte y Arbol.base por el campo PUNTO
Arbol.base.r.2<-merge(Ptos.sp.monte,Arbol.base,by="PUNTO",all.x=TRUE)

#Unir tablas Arbol.base.r.2 y Evalua.arbol por el campo ID_ARBOL
Evalua.arbol.r.2<-merge(Arbol.base.r.2,Evalua.arbol,by="ID_ARBOL",
                        all.x=TRUE)

#Cuenta de cada nivel de defoliación por punto
table(Evalua.arbol.r.2$DEFO,Evalua.arbol.r.2$PUNTO)

#Valor medio de defoliación por el campo PUNTO
tapply(Evalua.arbol.r.2$DEFO, Evalua.arbol.r.2$PUNTO, mean,na.rm=TRUE)

#Cuenta de cada nivel de defoliación por punto y campaña
table(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$CAMP==2001)],
      Evalua.arbol.r.2$PUNTO[which(Evalua.arbol.r.2$CAMP==2001)])

#Sin defoliación o defoliación ligera
defo.1<-aggregate(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$DEFO<25)]~
                    Evalua.arbol.r.2$PUNTO[which(Evalua.arbol.r.2$DEFO<25)]+
                    Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$DEFO<25)],
                  FUN = length)
names(defo.1)<-c("PUNTO","CAMP","CUENTA")
defo.1$DEFO<-"Ligera"

#Defoliación moderada
defo.2<-aggregate(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$DEFO>=25&Evalua.arbol.r.2$DEFO<60)]~
                    Evalua.arbol.r.2$PUNTO[which(Evalua.arbol.r.2$DEFO>=25&Evalua.arbol.r.2$DEFO<60)]+
                    Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$DEFO>=25&Evalua.arbol.r.2$DEFO<60)],
                  FUN = length)
names(defo.2)<-c("PUNTO","CAMP","CUENTA")
defo.2$DEFO<-"Moderada"

#Defoliación severa
defo.3<-aggregate(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$DEFO>=60&Evalua.arbol.r.2$DEFO<100)]~
                    Evalua.arbol.r.2$PUNTO[which(Evalua.arbol.r.2$DEFO>=60&Evalua.arbol.r.2$DEFO<100)]+
                    Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$DEFO>=60&Evalua.arbol.r.2$DEFO<100)],
                  FUN = length)
names(defo.3)<-c("PUNTO","CAMP","CUENTA")
defo.3$DEFO<-"Severa"

#Muertos en pie
defo.4<-aggregate(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$DEFO==100)]~
                    Evalua.arbol.r.2$PUNTO[which(Evalua.arbol.r.2$DEFO==100)]+
                    Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$DEFO==100)],
                  FUN = length)
names(defo.4)<-c("PUNTO","CAMP","CUENTA")
defo.4$DEFO<-"Muertos"

defo<-rbind(defo.1,defo.2)
defo<-rbind(defo,defo.3)
defo<-rbind(defo,defo.4)

Ptos.sp.monte.defo<-merge(Ptos.sp.monte,defo,by="PUNTO",all.x=TRUE)

#Guardar las características originales de las representaciones gráficas
opar<-par()

#Cambiar las características de representación para que en un sólo gráfico se puedan incluir los 12 puntos en 4 filas de 3 columnas
par(mfrow=c(4,3),cex=0.45)

#Boxplot del punto SN0201
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0201")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0201")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0201")

#Boxplot del punto SN0203
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0203")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0203")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0203")

#Boxplot del punto SN0204
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0204")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0204")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0204")

#Boxplot del punto SN0205
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0205")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0205")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0205")

#Boxplot del punto SN0206
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0206")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0206")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0206")

#Boxplot del punto SN0210
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0210")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0210")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0210")

#Boxplot del punto SN0211
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0211")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0211")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0211")

#Boxplot del punto SN0212
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0212")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0212")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0212")

#Boxplot del punto SN0213
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0213")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0213")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0213")

#Boxplot del punto SN0221
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0221")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0221")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0221")

#Boxplot del punto SN0222
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0222")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0222")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0222")

#Boxplot del punto SN0230
boxplot(Evalua.arbol.r.2$DEFO[which(Evalua.arbol.r.2$PUNTO=="SN0230")]~Evalua.arbol.r.2$CAMP[which(Evalua.arbol.r.2$PUNTO=="SN0230")],
        xlab="Año",ylab="% Defoliación",ylim=c(0,100),main="Punto SN0230")

#Cambiar las características de representación para que en un sólo gráfico se puedan incluir los 12 puntos en 4 filas de 3 columnas
par(mfrow=c(4,3),cex=0.45)

#Gráfico por clases de defoliación del punto SN0201
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0201")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0201")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0201")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0201")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0201")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0201")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0201")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0201")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0201")],
       ylim=c(0,25),pch=19,col="red",type="b")


#Gráfico por clases de defoliación del punto SN0203
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0203")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0203")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0203")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0203")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0203")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0203")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0203")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0203")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0203")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0204
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0204")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0204")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0204")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0204")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0204")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0204")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0204")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0204")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0204")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0205
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0205")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0205")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0205")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0205")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0205")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0205")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0205")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0205")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0205")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0206
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0206")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0206")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0206")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0206")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0206")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0206")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0206")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0206")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0206")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0210
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0210")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0210")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0210")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0210")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0210")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0210")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0210")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0210")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0210")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0211
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0211")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0211")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0211")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0211")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0211")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0211")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0211")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0211")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0211")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0212
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0212")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0212")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0212")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0212")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0212")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0212")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0212")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0212")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0212")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0213
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0213")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0213")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0213")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0213")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0213")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0213")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0213")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0213")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0213")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0221
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0221")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0221")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0221")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0221")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0221")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0221")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0221")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0221")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0221")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0222
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0222")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0222")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0222")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0222")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0222")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0222")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0222")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0222")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0222")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Gráfico por clases de defoliación del punto SN0230
plot(defo$CAMP[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0230")],
     defo$CUENTA[which(defo$DEFO=="Ligera"&defo$PUNTO=="SN0230")],
     ylim=c(0,25),pch=19,col="darkgreen",type="b",
     xlab="Año",ylab="Nº pies",main="Punto SN0230")
points(defo$CAMP[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0230")],
       defo$CUENTA[which(defo$DEFO=="Moderada"&defo$PUNTO=="SN0230")],
       ylim=c(0,25),pch=19,col="chartreuse",type="b")
points(defo$CAMP[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0230")],
       defo$CUENTA[which(defo$DEFO=="Severa"&defo$PUNTO=="SN0230")],
       ylim=c(0,25),pch=19,col="orange",type="b")
points(defo$CAMP[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0230")],
       defo$CUENTA[which(defo$DEFO=="Muertos"&defo$PUNTO=="SN0230")],
       ylim=c(0,25),pch=19,col="red",type="b")

#Recuperación de las características originales de las representaciones gráficas
par(opar)

#Activación de librería 
library(plotrix)

#Rampas de color para cada grupo
pal.ligera <- colorRampPalette(c("darkolivegreen1", "darkgreen"))
pal.moderada <- colorRampPalette(c("chartreuse", "chartreuse4"))
pal.severa <- colorRampPalette(c("yellow", "darkorange4"))
pal.muertos <- colorRampPalette(c("orange", "darkred"))

addLegendToSFPlot <- function(values = c(0, 1), labels = c("Low", "High"), 
                              palette = c("blue", "red"), ...){
  
  # Get the axis limits and calculate size
  axisLimits <- par()$usr
  xLength <- axisLimits[2] - axisLimits[1]
  yLength <- axisLimits[4] - axisLimits[3]
  
  # Define the colour palette
  colourPalette <- leaflet::colorNumeric(palette, range(values))
  
  # Add the legend
  plotrix::color.legend(xl=axisLimits[2]-0.1*xLength, xr=axisLimits[2],
                        yb=axisLimits[3], yt=axisLimits[3]+0.1* yLength,
                        legend= labels, rect.col=colourPalette(values), 
                        gradient="y", ...)
}

#Cambiar las características de representación para que en un sólo gráfico se puedan incluir los 4 tipos de defoliación, cada uno en un mapa
par(mfrow=c(2,2),mar=c(0,0,0,0),cex.lab=0.5,bg=NA,
    oma=c(0,0,2,0),res=1000)

#Gráfico clases de defoliación ligera
plot(st_geometry(Pinar.Yunquera),axes=TRUE)
plot(Ptos.sp.monte.defo[which(Ptos.sp.monte.defo$DEFO=="Ligera"&
                                Ptos.sp.monte.defo$CAMP==2001),
                        13],col=pal.ligera(24),pch=19,cex=2,add=TRUE)
addLegendToSFPlot(values = seq(1,24,1), 
                  labels = c(1,12,24),
                  palette = c("darkolivegreen1", "darkgreen"),cex=0.5)

#Corrección de márgenes para el nuevo gráfico
par(mar = c(0,0,0,0))

#Gráfico clases de defoliación moderada
plot(st_geometry(Pinar.Yunquera),axes=TRUE)
plot(Ptos.sp.monte.defo[which(Ptos.sp.monte.defo$DEFO=="Moderada"&
                                Ptos.sp.monte.defo$CAMP==2001),
                        13],col=pal.moderada(24),pch=19,cex=2,add=TRUE)
addLegendToSFPlot(values = seq(1,24,1), 
                  labels = c(1,12,24),
                  palette = c("chartreuse", "chartreuse4"),cex=0.5)

#Corrección de márgenes para el nuevo gráfico
par(mar = c(0,0,0,0))

#Gráfico clases de defoliación severa
plot(st_geometry(Pinar.Yunquera),axes=TRUE)
plot(Ptos.sp.monte.defo[which(Ptos.sp.monte.defo$DEFO=="Severa"&
                                Ptos.sp.monte.defo$CAMP==2001),
                        13],col=pal.severa(24),pch=19,cex=2,add=TRUE)
addLegendToSFPlot(values = seq(1,24,1), 
                  labels = c(1,12,24),
                  palette = c("darkorange", "darkorange4"),cex=0.5)

#Corrección de márgenes para el nuevo gráfico
par(mar = c(0,0,0,0))

#Gráfico clases de defoliación muertos
plot(st_geometry(Pinar.Yunquera),axes=TRUE)
plot(Ptos.sp.monte.defo[which(Ptos.sp.monte.defo$DEFO=="Muertos"&
                                Ptos.sp.monte.defo$CAMP==2001),
                        13],col=pal.muertos(24),pch=19,cex=2,add=TRUE)
addLegendToSFPlot(values = seq(1,24,1), 
                  labels = c(1,12,24),
                  palette = c("brown1", "darkred"),cex=0.5)

mtext(2001,outer=TRUE)

#Recuperación de las características originales de las representaciones gráficas
par(opar)
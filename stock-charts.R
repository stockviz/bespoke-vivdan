#how to use: 
#add/remove tickers to the 'symbols' array to start/stop following them
#change 'lookbackDays' to specify number of historical business days to plot
#add technical charts to the TA list. See quantmod documentation for possibilities

symbols<-c('HDFC', 'HDFCBANK', 'TATAELXSI')
lookbackDays<-220

library('RODBC')
library('quantmod')
library('PerformanceAnalytics')
library('extrafont')

source("d:/stockviz/r/config.r")
reportPath<-"D:/StockViz/public/bespoke-vivdan/reports"

lcon <- odbcDriverConnect(sprintf("Driver={SQL Server};Server=%s;Database=%s;Uid=%s;Pwd=%s;", ldbserver, ldbname, ldbuser, ldbpassword), case = "nochange", believeNRows = TRUE)

for(i in 1:length(symbols)){
	sym<-toString(symbols[i])
	
	data<-sqlQuery(lcon, sprintf("select top %d TIME_STAMP, PX_OPEN [Open], PX_HIGH [High], PX_LOW [Low], PX_CLOSE [Close], TOT_TRD_QTY [Volume] from PX_HISTORY 
							where SYMBOL='%s' and (series='eq' or series='be')
							order by time_stamp desc", lookbackDays, sym))

	if(length(data[,1]) < lookbackDays/2) next
	
	dXts<-xts(data[,-1], as.Date(data[,1]))
	
	png(sprintf("%s/%s.px.png", reportPath, sym), bg="white", width=1200, height=800)
	par(family='Segoe UI')
	chartSeries(dXts, TA=list("addSMA(50, col='red')"), theme='white', name=sprintf("NSE: %s [%.2f, %.2f] @StockViz", sym, min(data$Close), max(data$Close)))
	dev.off()
}




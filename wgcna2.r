# load expression data
load('datExpr.RData')

if(dim(datExpr)[2]^2 > 2^31){
    print('Now, Data is too huge to handle for WGCNA!\n
    You could trim you data or follow the block-wise-
    network-construction script in WGCNA.')
    quit(save='no')
}

# environment
library(WGCNA)
options(stringsAsFactors=FALSE)
enableWGCNAThreads(6)

# softpower
softPower = 7 

# unsigned type
adjacency = adjacency(datExpr, power = softPower)
save(file='adjMat.RData', adjacency)
TOM = TOMsimilarity(adjacency)
dissTOM = 1 - TOM
save(file='dissTOM.RData', dissTOM)
#load('dissTOM.RData')
geneTree = hclust(as.dist(dissTOM), method='average')
minModuleSize = 30

dynamicMods = cutreeDynamic(dendro = geneTree, distM = dissTOM, deepSplit = 4,
pamRespectsDendro = FALSE, minClusterSize = minModuleSize) 

dynamicColors = labels2colors(dynamicMods)

MEList = moduleEigengenes(datExpr, colors = dynamicColors)
MEs = MEList$eigengenes
MEDiss = 1 - cor(MEs)
METree = hclust(as.dist(MEDiss), method = 'average')

# plot genetree cluster
#pdf(file = 'GeneTreeCluster.pdf', wi=12, he=9)
#plot(METree, main= 'Clustering of module eigengenes', xlab = '', sub = '', cex.lab = 0.6, cex.axis = 0.8)
#dev.off()

# plot module eigengenes cluster
MEDissThres = 0.25
#pdf(file = 'ClusterModuleEigengenes.pdf', wi=12, he=9)
#plot(METree, main='Clustering of module eigengenes', xlab = '', sub = '')
#abline(h=MEDissThres, col = 'red')
#dev.off()

# module merge
merge = mergeCloseModules(datExpr, dynamicColors, cutHeight = MEDissThres , verbose = 3)
mergedColors = merge$colors
mergedMEs = merge$newMEs
pdf(file = 'BeforeAndAfterMerge.pdf', wi=12, he=9)
plotDendroAndColors(geneTree, cbind(dynamicColors, mergedColors), dendroLabels
= FALSE, hang = 0.03, addGuide = TRUE, guideHang = 0.05)
dev.off()
png(file = 'BeforeAndAfterMerge.png', wi=2000, he=1600)
plotDendroAndColors(geneTree, cbind(dynamicColors, mergedColors), dendroLabels
= FALSE, hang = 0.03, addGuide = TRUE, guideHang = 0.05)
dev.off()

moduleColors = mergedColors
colorOrder = c('grey', standardColors(100))
moduleLabels = match(moduleColors, colorOrder) - 1
MEs = mergedMEs
save(file='dynamic_merged_networkdata.RData', MEs, moduleLabels, moduleColors,
geneTree, dynamicMods)

intramoduleConectivity = intramodularConnectivity(adjacency, moduleColors)
intramoduleConectivity = cbind(intramoduleConectivity, moduleColors)
write.table(intramoduleConectivity, file='intramoduleConectivity_all.xls', sep='\t', quote=F, col.names=NA)

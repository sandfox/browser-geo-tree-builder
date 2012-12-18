###
Really Hacky Script to generate the kdtree and record files
usage  $ bin/csv2GeoJSON {ARGS}

look at https://gist.github.com/85f5ab526a9158b2cd30 for a hint on how to use this

TODO :	allow this output straight to gzip
		use ssmaller datasctructure and publish entire package for browsers
		move the kdtree into it's own npm module

###



fs = require 'fs'
csv = require 'csv'
path = require 'path'
#We need to fix this location - or make it a seperate library
KDTree = require '../kdtree'
fmt = require 'fmt'
lingo = require 'lingo'
argv = require('optimist')
	#Completely batshit way of doing this....
	.usage(
		fmt.sep()
		+ fmt.field('program', 'csv2json')
		+ fmt.field('desc', 'produce index.json and json files for every record based upon input CSV')
		+ fmt.field('version', require('../package.json').version)
	)
	.demand(['f', 'o'])
	.alias(
		'f' : 'file'
		'o' : 'out'
		's' : 'single'
		'p'	: 'precision'
		'u' : 'attempt to de-uglify field names from the csv, default yes'
	)
	.describe(
		'f' : 'The CSV to parse'
		'o' : 'the folder to output the records to'
		's' : 'Output json in single file rather than index + records [bool]'
		'p' : 'number of decimal places to store lat/lons as, default 4'
	)
	.argv


#where we stash the values to build the kdtree with -will get rid of this one day
points = []

#our header config - we will kill this too at some point
columnLayout =
	x: null
	y: null
	other: []

stats =
	skippedRows: 0

#error logging
errorHandler = (err)->
	fmt.separator()
	fmt.dump  err, 'Error'
	process.exit()

#Just handles the header row
headerHandler = (record, index)->
	#console.log 'header--', record

	#lets search for rows automagically
	if record.indexOf 'latitude' isnt -1 then columnLayout.y = record.indexOf 'latitude'
	if record.indexOf 'longitude' isnt -1 then columnLayout.x = record.indexOf 'longitude'

	#lets fail if we don't have a header
	if not columnLayout.y? or not columnLayout.x?
		fmt.field 'Error', 'No header column found for latitude and/or longitude'
		process.exit()

	#only store columns which have a header row
	fmt.sep()
	fmt.field 'Total Header Columns', record.length
	for col,index in record
		if col
			prettyCol = lingo.camelcase(col.toLowerCase())
			columnLayout.other[prettyCol] = index
			fmt.subfield prettyCol, index + " [#{col}]"

	fmt.field 'Columns skipped', record.length - Object.keys(columnLayout.other).length

	#Do the event listener dance - this is silly but fun
	parser.removeListener 'record', headerHandler
	parser.on 'record', recordHandler

#handles normal record rows
recordHandler = (record, index)->


	#check if we have any x/y coord - if not bail as this will screw up the tree
	if record[columnLayout.x]? and record[columnLayout.y]?
		x = parseFloat record[columnLayout.x]
		y = parseFloat record[columnLayout.y]
	else
		#skip record
		stats.skippedRows++
		null

	tmpRecord = {}
	for col,i of columnLayout.other

		tmpRecord[col] = record[i]

	if not argv.single
		fs.writeFileSync path.join(argv.out, index + ".json"), JSON.stringify(tmpRecord)

	#This seems inefficient
	struct =
		x: x.toFixed precision
		y: y.toFixed precision
		id: index

	if argv.single
		struct.data = tmpRecord

	points.push struct
	null

endHandler = (count)->
	fmt.sep()
	fmt.title "Processing finished"
	fmt.field "Rows proccessed", count
	fmt.field "Rows skipped", stats.skippedRows

	fs.writeFileSync path.join(argv.out, "index.json"), JSON.stringify(new KDTree points)


#check the path we are going to output stuff really exists
if not fs.statSync(argv.out).isDirectory()
	fmt.field 'Error', 'output folder appears not to be a folder'
	process.exit()

# This default precision of 4 gives about accuracy to about 11 metres
# http://wiki.xkcd.com/geohashing/GPS_accuracy
precision = if argv.precision? then argv.precision else 4

parser = csv()
	.from.stream(fs.createReadStream(argv.file))
	.on('error', errorHandler)
	.on('record', headerHandler)
	.on('end', endHandler)

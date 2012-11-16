###
Script to generate the kdtree and record files
usage  node storeMaker.js
###


fs = require 'fs'
csv = require 'csv'
path = require 'path'
KDTree = require './kdtree'
argv = require('optimist')
	.usage('produce index.json and json files for every records based upon input CSV')
	.demand(['f', 'o'])
	.alias(
		'f' : 'file'
		'o' : 'out'
	)
	.describe(
		'f' : 'The CSV to parse'
		'o' : 'the folder to output the records to'
	)
	.argv


#where we stash the values to build the kdtree with -will get rid of this
points = []

#our header config - we will kill this too at some point
columnLayout =
	x: null
	y: null
	other: []

#error logging
errorHandler = (err)->
	console.log 'error--', err

#Just handles the header row
headerHandler = (record, index)->
	#console.log 'header--', record

	#lets search for rows automagically
	if record.indexOf 'latitude' isnt -1 then columnLayout.x = record.indexOf 'latitude'
	if record.indexOf 'longitude' isnt -1 then columnLayout.y = record.indexOf 'longitude'

	#only store things which have a header row
	
	for col,index in record
		if col
			columnLayout.other[col] = index

	#Do the event listener dance
	parser.removeListener 'record', headerHandler
	parser.on 'record', recordHandler

#handles normal record rows
recordHandler = (record, index)->

	tmpRecord = {}
	for col,i of columnLayout.other

		tmpRecord[col] = record[i]

	fs.writeFileSync path.join(argv.out, index + ".json"), JSON.stringify(tmpRecord)

	points.push
		x: record[columnLayout.x]
		y: record[columnLayout.y]
		id: index
	null

endHandler = (count)->
	console.log "Processed #{count} rows"
	#console.log points
	fs.writeFileSync path.join(argv.out, "index.json"), JSON.stringify(new KDTree points)

	t = new KDTree points
	a = t.getNearestNeighbour {x:3, y:0}
	console.log a

#check the path we are going to output stuff really exists
if not fs.statSync(argv.out).isDirectory() then process.exit 'output folder appears not to be a folder'


parser = csv()
	.from.stream(fs.createReadStream(argv.file))
	.on('error', errorHandler)
	.on('record', headerHandler)
	.on('end', endHandler)

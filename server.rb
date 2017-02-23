require 'webrick'
require 'oj'
include WEBrick

CONTENT_DIR = 'content'.freeze

def chunk_callback
  ->(_req, resp) { resp.chunked = true }
end

server = HTTPServer.new(Port: ENV['PORT'] ? ENV['PORT'].to_i : 3005,
                        DocumentRoot: Dir.pwd,
                        OutputBufferSize: 8192,
                        RequestCallback: chunk_callback)

server.mount_proc '/mhv-api/patient/v1/session' do |_req, res|
  res['Server'] = 'Apache-Coyote/1.1'
  res['Content-Length'] = 0
  res['Date'] = 'Tue, 10 May 2016 16:30:17 GMT'
  res['Expires'] = 'Tue, 10 May 2017 16:40:17 GMT'
  res['Token'] = 'bXkgdm9pY2UgaXMgbXkgcGFzc3BvcnQ='
  res['Connection'] = 'close'
  res.chunked = false
  res.body = ''
end

server.mount_proc '/mhv-api/patient/v1/bluebutton/generate' do |req, res|
  res['Server'] = 'Apache-Coyote/1.1'
  res['Date'] = 'Tue, 10 May 2016 16:30:17 GMT'
  res['Expires'] = 'Tue, 10 May 2017 16:40:17 GMT'
  res['Token'] = req['Token']
  res['Connection'] = 'keep-alive'
  res['Content-Type'] = 'application/json'
  body = { 'status' => 'ok', 'description' => nil, 'nextDate' => {} }
  res.chunked = false
  res.body = Oj.dump(body)
end

server.mount_proc '/mhv-api/patient/v1/bluebutton/geteligibledataclass' do |req, res|
  res['Server'] = 'Apache-Coyote/1.1'
  res['Date'] = 'Tue, 10 May 2016 16:30:17 GMT'
  res['Content-Type'] = 'application/json'
  body = { 'dataClasses' => 
    %w(seiactivityjournal seiallergies seidemographics familyhealthhistory 
       seifoodjournal healthcareproviders healthinsurance seiimmunizations 
       labsandtests medicalevents medications militaryhealthhistory 
       seimygoalscurrent seimygoalscompleted treatmentfacilities 
       vitalsandreadings prescriptions medications vaallergies 
       vaadmissionsanddischarges futureappointments pastappointments 
       vademographics vaekg vaimmunizations vachemlabs vaprogressnotes 
       vapathology vaproblemlist varadiology vahth wellness dodmilitaryservice)
  }
  res.chunked = false
  res.body = Oj.dump(body)
end

server.mount_proc '/mhv-api/patient/v1/bluebutton/extractstatus' do |req, res|
  res['Server'] = 'Apache-Coyote/1.1'
  res['Date'] = 'Tue, 10 May 2016 16:30:17 GMT'
  res['Content-Type'] = 'application/json'
  body = { "facilityExtractStatusList": [
    {"extractType":"ChemistryHematology","lastUpdated":"Thu, 19 Jan 2017 14:37:50 EST","status":"OK","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""},
    {"extractType":"ImagingStudy","lastUpdated":"Thu, 19 Jan 2017 14:37:49 EST","status":"ERROR","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""},
    {"extractType":"VPR","lastUpdated":"Thu, 19 Jan 2017 14:37:59 EST","status":"OK","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""},
    {"extractType":"DodMilitaryService","lastUpdated":"Thu, 19 Jan 2017 14:37:48 EST","status":"OK","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""},
    {"extractType":"WellnessReminders","lastUpdated":"Thu, 19 Jan 2017 14:37:58 EST","status":"OK","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""},
    {"extractType":"Allergy","lastUpdated":"Thu, 19 Jan 2017 14:37:52 EST","status":"OK","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""},
    {"extractType":"Appointments","lastUpdated":"Thu, 19 Jan 2017 14:37:48 EST","status":"ERROR","createdOn":"Thu, 19 Jan 2017 14:37:47 EST","stationNumber":""}
  ]}
  res.chunked = false
  res.body = Oj.dump(body)
end

def random_pdf
  open(Dir.glob(CONTENT_DIR + '/*.pdf').sample)
end

server.mount_proc '/mhv-api/patient/v1/bluebutton/bbreport/pdf' do |req, res|
  res['Server'] = 'Apache-Coyote/1.1'
  res['Date'] = 'Tue, 10 May 2016 16:30:17 GMT'
  res['Expires'] = 'Tue, 10 May 2017 16:40:17 GMT'
  res['Token'] = req['Token']
  f = random_pdf
  puts f.path
  res['Content-Disposition'] = "inline; filename=#{f.path}"
  res['Content-Type'] = 'application/pdf'
  res.chunked = true
  res.body = f
end

def random_txt
  open(Dir.glob(CONTENT_DIR + '/*.txt').sample)
end

server.mount_proc '/mhv-api/patient/v1/bluebutton/bbreport/txt' do |req, res|
  res['Server'] = 'Apache-Coyote/1.1'
  res['Date'] = 'Tue, 10 May 2016 16:30:17 GMT'
  res['Expires'] = 'Tue, 10 May 2017 16:40:17 GMT'
  res['Token'] = req['Token']
  f = random_txt
  puts f.path
  res['Content-Disposition'] = "inline; filename=#{f.path}"
  res['Content-Type'] = 'text/plain'
  res.body = f
end

trap('INT') { server.shutdown }

server.start

# mock-health-records-api

Simple HTTP service that responds to the same paths as the health records
endpoint. 

Most data is entirely static, but a request for the PDF or txt report data
will pull a random file of the appropriate type from the `content/` directory.
In this way it is possible to adjust the payload size returned and the
distribution of sizes, by adjusting the contents of that directory.

This mock service is designed to simulate the content chunking strategy used
by the real health records endpoint for large file downloads.

Run with `PORT=<port> ruby server.rb`. Port defaults to 3005.

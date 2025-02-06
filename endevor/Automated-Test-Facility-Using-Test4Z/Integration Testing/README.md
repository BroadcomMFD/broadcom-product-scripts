# Integration Testing

You may want to separate testing from single programs to conduct Integration testing, where your entire application is tested. 

The processors in this folder allows you conduct lists of tests, defined in your choice format:

- *keyword = 'list of Test_Suites'* - the traditional format consistent with CONPARMX 
- *Yaml* - a modern Mark-up language

An example for each is provided in the **Integration Testing** folder

You can choose which format you want, and the processor will act accordingly. A "#' (hash character) in the first position of the first record tells the processor you are using a Yaml version.

You can mix both formats in the same element type, if desired. The processor is able to detect by element, which format is used.
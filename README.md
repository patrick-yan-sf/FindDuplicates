# SFDX  App
    This is an apex project that will loop through your contacts/accounts or other duplicate matched objects and create a duplicate record set for the duplicates.  The user can then merge them or perform other operations on the results.
## Dev, Build and Test

The code is entirely encapsulated in a single Apex class.  This is mostly a proof of concept at this point.  So feel free to take the ideas from this and explore better ways to handle the duplicate finding.

The general flow is:
* Get all the contacts in your org (this is where the batching would be needed) and use the existing salesforce find duplicate function to check if there are duplicates.  
* The code thus depends on the matching rules and duplicate rules that you have defined.
* Loop through the find duplicate results and create DuplicateRecordSets for each record that has duplicates
* If Record A might be a duplicate of B or C then the duplicate record set should have 3 record items

## Resources


## Description of Files and Directories
- DuplicateFinder.cls - APEX class with simple POC of the functionality


## Issues
There are still many things that needs to be done.
- The DuplicateFinder class should implement scheduleable and the queueable interface so that it can be run on a schedule
and process all the records in the org
- Currently we simply pass in a list of contacts but the exact fields that need to be selected and the way the contacts are 
passed in need to be improved.
- How to handle the duplicates that have already been found?  The current list of contacts in a Set will run out of memory.
- There are no test classes so this would not be deployable yet
- You can add new fields to the duplicate set and record items objects to store stuff like match confidence or something else



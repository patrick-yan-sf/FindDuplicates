# SFDX  App
    This is an apex project that will loop through your contacts/accounts or other duplicate matched objects and create a duplicate record set for the duplicates.  The user can then merge them or perform other operations on the results.
## Dev, Build and Test


## Resources


## Description of Files and Directories


## Issues
There are still many things that needs to be done.
- The DuplicateFinder class should implement scheduleable and the queueable interface so that it can be run on a schedule
and process all the records in the org
- Currently we simply pass in a list of contacts but the exact fields that need to be selected and the way the contacts are 
passed in need to be improved.
- How to handle the duplicates that have already been found?  The current list of contacts in a Set will run out of memory.



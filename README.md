# SFDX  App
    This is an apex project that will loop through your contacts/accounts or other duplicate matched objects and create a duplicate record set for the duplicates.  The user can then merge them or perform other operations on the results.
## Dev, Build and Test

The code is entirely encapsulated in a single Apex class.  This is mostly a proof of concept at this point.  So feel free to take the ideas from this and explore better ways to handle the duplicate finding.

The general flow is:
* Get all the contacts in your org (this is where the batching would be needed) and use the existing salesforce find duplicate function to check if there are duplicates.  
* The code thus depends on the matching rules and duplicate rules that you have defined.
* Loop through the find duplicate results and create DuplicateRecordSets for each record that has duplicates
* If Record A might be a duplicate of B or C then the duplicate record set should have 3 record items

## How to Use
1. Setup a [Contact Duplicate Rule](https://help.salesforce.com/articleView?id=duplicate_rules_map_of_reference.htm&type=5)
2. Make sure you have some Contacts that would be flagged as duplicates by rule
3. Open Developer Console
4. Click **File -> New -> Apex Class**
5. Copy the text from [DuplicateFinder.cls](src/classes/DuplicateFinder.cls)
6. Paste in the new Apex Classy file and click **File -> Save**
7. Click **Debug -> Open Execute Anonymous Window**
8. Paste `DuplicateFinder.findAllDuplicateContacts();` and click **Execute**
9. Navigate to [Duplicate Record Sets](https://help.salesforce.com/articleView?id=duplicate_management_duplicate_record_sets.htm&type=5) and you should see newly created ones related to the potential duplicate Duplicate Record Items which relate to potential duplicate Contacts and the Duplicate Rule

Note: Currently, this method will only evaluate an org with 100 Contacts.

## [Video Demo](/FindDuplicates-Demo-Video.mov?raw=true)

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



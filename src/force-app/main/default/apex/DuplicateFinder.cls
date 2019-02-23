/* *********************************
 * DuplicateFinder Class 
 * @description     This class uses the built in duplicate search feature of salesforce to identify
 *                  duplicates in a bulk manner
 *
 *                  Class should be run without sharing so that all records can be searched
 *
 *                  Class should implement the queueable interface so that it can iteratively process 
 *                  all the records in the organization
 */

public without sharing class DuplicateFinder {
    public DuplicateFinder() {

    }

    private Map<String, DuplicateRule> getDuplicateRules() {
        Map<String, DuplicateRule> ruleMap = new Map<String, DuplicateRule>();
        
        List<DuplicateRule> duplicateRules = [SELECT Id, DeveloperName FROM DuplicateRule LIMIT 100];
        for (DuplicateRule dr : duplicateRules) {
            ruleMap.put(dr.DeveloperName, dr);
        }

        return ruleMap;
    }

    public static List<DuplicateSetInfo> findAllDuplicateContacts() {
        List<Contact> contacts = [SELECT Id, Name, Email, Phone FROM Contact LIMIT 100];
        return findDuplicates(contacts);
    }

    public static List<DuplicateSetInfo> findDuplicates(List<SObject> objects) {

        DuplicateFinder finder = new DuplicateFinder();
        Map<String, DuplicateRule> ruleMap = finder.getDuplicateRules(); 
        Set<String> currentDupIds = new Set<String>();

        List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(objects);

        List<DuplicateSetInfo> duplicateSets = new List<DuplicateSetInfo>();
        List<DuplicateRecordSet> parentRecords = new List<DuplicateRecordSet>(); 

        // Each record in the original list will result in a find duplicate result object
        Integer recordSearchSize = objects.size();

        for (Integer i = 0; i<recordSearchSize; i++) {
            String listRecordId = objects[i].Id;
            // skip if record is already in a previous duplicate Set
            if (currentDupIds.contains(listRecordId)) {
                continue;
            }

            Datacloud.FindDuplicatesResult findDupeResult = results[i];
        
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
        
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
        
                    // basically if it is a duplicate then create a set for it
                    if (matchResult.getSize() > 0) {
                        Boolean addToInsertList = false;
                        // Need to create one for the current record as well
                        
                        // need to add the duplicate record id to a list so that we do not try to create 
                        // another set for it
                        DuplicateSetInfo dsi = new DuplicateSetInfo();
                        // Also need to add the object that is currently being reviewed

                        DuplicateRecordSet duplicateSet = new DuplicateRecordSet();
                        duplicateSet.duplicateRuleId = (ruleMap.get(dupeResult.getDuplicateRule())).Id;
                        dsi.duplicateSet = duplicateSet;

                        DuplicateRecordItem recordItem = new DuplicateRecordItem(
                            RecordId = listRecordId
                        );
                        dsi.duplicateItems.add(recordItem);

                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            DuplicateRecordItem duplicateItem = new DuplicateRecordItem(
                                RecordId = (matchRecord.getRecord()).Id
                            );

                            currentDupIds.add(duplicateItem.RecordId);
                            dsi.duplicateItems.add(duplicateItem);
                            addToInsertList = true;
                        }

                        if (addToInsertList) {
                            parentRecords.add(duplicateSet);
                            duplicateSets.add(dsi);
                        }

                    }
                }
            }
        }


        // save the top level duplicate set first
        if (!parentRecords.isEmpty()) {
            insert parentRecords;

            List<DuplicateRecordItem> childRecords = new List<DuplicateRecordItem>();
            for (DuplicateSetInfo dsi : duplicateSets) {
                dsi.prepareForInsert();
                childRecords.addAll(dsi.duplicateItems);
            }

            insert childRecords;
        }


        return duplicateSets;
    }

    public class DuplicateSetInfo {
        public DuplicateRecordSet duplicateSet;
        public List<DuplicateRecordItem> duplicateItems;

        public DuplicateSetInfo() {
            duplicateItems = new List<DuplicateRecordItem>();
        }

        public void prepareForInsert() {
            for (DuplicateRecordItem recordItem : duplicateItems) {
                recordItem.DuplicateRecordSetId = duplicateSet.Id;
            }
        }


    }


}


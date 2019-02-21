public with sharing class DuplicateFinder {
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

    public static List<DuplicateSetInfo> findDuplicates(List<SObject> objects) {

        DuplicateFinder finder = new DuplicateFinder();
        Map<String, DuplicateRule> ruleMap = finder.getDuplicateRules(); 

        List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(objects);

        List<DuplicateSetInfo> duplicateSets= new List<DuplicateSetInfo>();

        // Each record in the original list will result in a find duplicate result object
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
        
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
        
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
        
                    if (matchResult.getSize() > 0) {

                        DuplicateSetInfo dsi = new DuplicateSetInfo();

                        DuplicateRecordSet duplicateSet = new DuplicateRecordSet();
                        duplicateSet.duplicateRuleId = (ruleMap.get(dupeResult.getDuplicateRule())).Id;
                        dsi.duplicateSet = duplicateSet;

                        duplicateSets.add(dsi);

                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            DuplicateRecordItem duplicateItem = new DuplicateRecordItem(
                                RecordId = (matchRecord.getRecord()).Id
                            );
                            dsi.duplicateItems.add(duplicateItem);
                        }

                        dsi.prepareForInsert();
                    }
                }
            }
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


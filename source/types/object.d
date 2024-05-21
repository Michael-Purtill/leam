module types.object;
import std.sumtype;

// A generic object for representing JSON, YAML, and TOML
class ConfigObject {
  // a type which represents a *single* valid type for a given record object.
  alias RecordData = SumType!(int, float, string, ConfigObject);
  // a given key can point to a single value, or many (an array of record values).
  alias RecordDataRecursive = SumType!(RecordData[], RecordData);

  RecordDataRecursive[string] records;

  this() {
    // set up records to be empty array.
    // this looks weird and very not-D-like but seems to be recommended practice for initting empty associative arrays
    records = null; 
  }

  void upsert(string key, RecordDataRecursive value) {
    records[key] = value;
  }

  void remove(string key) {
    records.remove(key);
  }

  // string toJSON() {

  // }

  // string toYAML() {

  // }

  // string toTOML() {

  // }

}
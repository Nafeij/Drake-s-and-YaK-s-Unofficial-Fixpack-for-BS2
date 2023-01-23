package engine.core.pref
{
   public interface IPrefBag
   {
       
      
      function setPref(param1:String, param2:*) : *;
      
      function getPref(param1:String, param2:* = undefined) : *;
      
      function getDefault(param1:String) : *;
      
      function reset() : void;
      
      function savePrefs() : void;
      
      function get valid() : Boolean;
   }
}

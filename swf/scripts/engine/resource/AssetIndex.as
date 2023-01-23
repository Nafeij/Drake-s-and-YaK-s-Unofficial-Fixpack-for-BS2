package engine.resource
{
   import flash.utils.Dictionary;
   
   public class AssetIndex
   {
       
      
      private var m_pathToHash:Dictionary;
      
      private var m_hashedPrefix:String;
      
      public function AssetIndex(param1:XML)
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         this.m_pathToHash = new Dictionary();
         super();
         if(!param1)
         {
            return;
         }
         this.m_hashedPrefix = param1.@hashedPrefix;
         var _loc2_:XMLList = param1.text();
         var _loc3_:String = _loc2_[0];
         var _loc4_:RegExp = /\r/g;
         var _loc5_:String = _loc3_.replace(_loc4_,"");
         var _loc6_:Array = _loc5_.split("\n");
         for each(_loc7_ in _loc6_)
         {
            _loc8_ = _loc7_.indexOf(":");
            _loc9_ = _loc7_.substr(0,_loc8_);
            _loc10_ = _loc7_.substr(_loc8_ + 1);
            _loc11_ = getExtensionFromPath(_loc10_);
            this.m_pathToHash[_loc10_] = _loc9_ + "." + _loc11_;
         }
      }
      
      public static function getExtensionFromPath(param1:String) : String
      {
         var _loc2_:int = param1.lastIndexOf(".");
         if(_loc2_ >= 0)
         {
            return param1.substr(_loc2_ + 1);
         }
         return null;
      }
      
      public function getHashFromPath(param1:String) : String
      {
         if(this.m_pathToHash.hasOwnProperty(param1))
         {
            return this.m_pathToHash[param1];
         }
         return null;
      }
      
      public function getHashUrlFromPath(param1:String) : String
      {
         var _loc2_:String = this.getHashFromPath(param1);
         if(_loc2_)
         {
            return this.m_hashedPrefix + _loc2_;
         }
         return null;
      }
   }
}

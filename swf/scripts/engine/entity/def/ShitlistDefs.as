package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import flash.utils.Dictionary;
   
   public class ShitlistDefs
   {
       
      
      public var shitlistDefs:Vector.<ShitlistDef>;
      
      public var byId:Dictionary;
      
      public function ShitlistDefs()
      {
         this.shitlistDefs = new Vector.<ShitlistDef>();
         this.byId = new Dictionary();
         super();
      }
      
      public function get hasShitlistDefs() : Boolean
      {
         return Boolean(this.shitlistDefs) && Boolean(this.shitlistDefs.length);
      }
      
      public function getShitlistDefById(param1:String) : ShitlistDef
      {
         return this.byId[param1];
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ShitlistDefs
      {
         var json:Object = param1;
         var logger:ILogger = param2;
         var va:Array = json as Array;
         if(!va)
         {
            throw new ArgumentError("outer json object is not an array");
         }
         this.shitlistDefs = ArrayUtil.arrayToDefVector(va,ShitlistDef,null,this.shitlistDefs,function(param1:ShitlistDef, param2:int):void
         {
            byId[param1.id] = param1;
         }) as Vector.<ShitlistDef>;
         return this;
      }
      
      public function toJson(param1:Boolean = false) : Object
      {
         if(this.shitlistDefs)
         {
            return ArrayUtil.defVectorToArray(this.shitlistDefs,true,param1);
         }
         return [];
      }
   }
}

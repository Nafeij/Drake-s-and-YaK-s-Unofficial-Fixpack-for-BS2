package engine.anim.def
{
   import flash.utils.Dictionary;
   
   public class AnimDefLayer
   {
       
      
      public var animDefsByName:Dictionary;
      
      public var allAnimDefs:Vector.<IAnimDef>;
      
      public var explicitAnimDefs:Vector.<IAnimDef>;
      
      public var layer:String;
      
      public var sourceLayerId:String;
      
      public var omita:Array;
      
      public var omito:Array;
      
      public var omito_dict:Dictionary;
      
      public var omita_dict:Dictionary;
      
      public function AnimDefLayer(param1:String, param2:String, param3:Array, param4:Array)
      {
         var _loc5_:String = null;
         this.animDefsByName = new Dictionary();
         this.allAnimDefs = new Vector.<IAnimDef>();
         this.explicitAnimDefs = new Vector.<IAnimDef>();
         super();
         this.layer = param1;
         this.sourceLayerId = param2;
         this.omita = param3;
         this.omito = param4;
         if(param4)
         {
            this.omito_dict = new Dictionary();
            for each(_loc5_ in param4)
            {
               this.omito_dict[_loc5_] = true;
            }
         }
         if(param3)
         {
            this.omita_dict = new Dictionary();
            for each(_loc5_ in param3)
            {
               this.omita_dict[_loc5_] = true;
            }
         }
      }
      
      public function addAnimDef(param1:IAnimDef, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         if(param2)
         {
            this.explicitAnimDefs.push(param1);
         }
         var _loc3_:IAnimDef = this.animDefsByName[param1.name];
         if(_loc3_)
         {
            _loc4_ = this.allAnimDefs.indexOf(_loc3_);
            if(_loc4_ >= 0)
            {
               this.allAnimDefs[_loc4_] = param1;
            }
            else
            {
               this.allAnimDefs.push(param1);
            }
         }
         else
         {
            this.allAnimDefs.push(param1);
         }
         this.animDefsByName[param1.name] = param1;
      }
      
      public function hasAnimDef(param1:String) : Boolean
      {
         return this.animDefsByName[param1] != null;
      }
      
      public function isOmittedOrient(param1:String) : Boolean
      {
         return Boolean(this.omito_dict) && Boolean(this.omito_dict[param1]);
      }
      
      public function isOmittedAnim(param1:String) : Boolean
      {
         return Boolean(this.omita_dict) && Boolean(this.omita_dict[param1]);
      }
      
      public function cleanup() : void
      {
         this.animDefsByName = null;
         this.explicitAnimDefs = null;
         this.allAnimDefs = null;
      }
   }
}

package game.cfg
{
   import engine.resource.CompressedTextResource;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import flash.events.Event;
   
   public class NameGenerator
   {
       
      
      private var resman:ResourceManager;
      
      private var callback:Function;
      
      private var male_r:CompressedTextResource;
      
      private var female_r:CompressedTextResource;
      
      public var male:Vector.<String>;
      
      public var female:Vector.<String>;
      
      private var group:ResourceGroup;
      
      public var ready:Boolean;
      
      public function NameGenerator(param1:ResourceManager, param2:Function)
      {
         this.male = new Vector.<String>();
         this.female = new Vector.<String>();
         super();
         this.resman = param1;
         this.callback = param2;
         this.group = new ResourceGroup(this,param1.logger);
      }
      
      public function cleanup() : void
      {
         if(this.group)
         {
            this.group.removeResourceGroupListener(this.resourceGroupCompleteHandler);
            this.group.release();
            this.group = null;
            this.male_r = null;
            this.female_r = null;
         }
         this.male = null;
         this.female = null;
         this.resman = null;
         this.callback = null;
      }
      
      public function load() : void
      {
         this.male_r = this.resman.getResource("common/character/names_male.txt.z",CompressedTextResource,this.group) as CompressedTextResource;
         this.female_r = this.resman.getResource("common/character/names_female.txt.z",CompressedTextResource,this.group) as CompressedTextResource;
         this.group.addResourceGroupListener(this.resourceGroupCompleteHandler);
      }
      
      public function parse(param1:Vector.<String>, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc3_:Array = param2.split("\n");
         for each(_loc4_ in _loc3_)
         {
            param1.push(_loc4_);
         }
      }
      
      public function resourceGroupCompleteHandler(param1:Event) : void
      {
         this.group.removeResourceGroupListener(this.resourceGroupCompleteHandler);
         if(this.male_r.ok)
         {
            this.parse(this.male,this.male_r.text);
         }
         else
         {
            this.male.push("Name");
         }
         if(this.female_r.ok)
         {
            this.parse(this.female,this.female_r.text);
         }
         else
         {
            this.female.push("Name");
         }
         this.group.release();
         this.group = null;
         this.male_r = null;
         this.female_r = null;
         this.ready = true;
         if(this.callback != null)
         {
            this.callback(this);
         }
      }
      
      private function r(param1:int) : int
      {
         return Math.max(0,Math.round(Math.random() * (param1 - 0.5)));
      }
      
      public function get randomMale() : String
      {
         var _loc1_:int = this.r(this.male.length);
         return this.male[_loc1_];
      }
      
      public function get randomFemale() : String
      {
         var _loc1_:int = this.r(this.female.length);
         return this.female[_loc1_];
      }
   }
}

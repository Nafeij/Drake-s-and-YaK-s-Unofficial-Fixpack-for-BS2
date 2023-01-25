package engine.anim.def
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class AnimClipDefBag
   {
       
      
      public var clipsById:Dictionary;
      
      public var clips:Vector.<AnimClipDef>;
      
      private var logger:ILogger;
      
      private var reduction:Number = 1;
      
      public var url:String;
      
      private var bagCompleteCallback:Function;
      
      public var bagComplete:Boolean;
      
      private var clipConsumeWaits:int;
      
      private var clipConsumeWaiting:Boolean;
      
      private var cacheKey:uint = 2269777967;
      
      public function AnimClipDefBag(param1:ILogger)
      {
         this.clipsById = new Dictionary();
         this.clips = new Vector.<AnimClipDef>();
         super();
         this.logger = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:AnimClipDef = null;
         for each(_loc1_ in this.clips)
         {
            _loc1_.cleanup();
         }
         this.clips = null;
         this.bagCompleteCallback = null;
      }
      
      public function getClipDefById(param1:String) : AnimClipDef
      {
         return this.clipsById[param1];
      }
      
      public function loadCache(param1:ByteArray, param2:Boolean, param3:Function) : void
      {
         var _loc5_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:AnimClipDef = null;
         if(!param1 || param1.bytesAvailable < 4)
         {
            return;
         }
         this.bagCompleteCallback = param3;
         this.bagComplete = false;
         var _loc4_:uint = param1.readUnsignedInt();
         if(_loc4_ == this.cacheKey)
         {
            this.reduction = param1.readFloat();
            _loc5_ = true;
         }
         else
         {
            this.reduction = param2 ? Platform.qualityTextures : 1;
            param1.position -= 4;
         }
         var _loc6_:Boolean = true;
         if(this.url.indexOf(".portrait.") > 0)
         {
            _loc6_ = false;
         }
         while(param1.bytesAvailable)
         {
            _loc7_ = int(param1.position);
            _loc8_ = new AnimClipDef(this.logger);
            _loc8_.readBytes(param1);
            if(_loc5_)
            {
               _loc8_.consumeReducedSheet(param1,param1.position,this.logger);
            }
            else
            {
               _loc8_.consumeSheet(param1,param1.position,this.logger,param2,_loc6_,this.clipConsumptionCompleteCallback);
               if(!_loc8_.consumptionComplete)
               {
                  ++this.clipConsumeWaits;
               }
            }
            this.clips.push(_loc8_);
            this.clipsById[_loc8_.id] = _loc8_;
         }
         if(this.clipConsumeWaits)
         {
            this.clipConsumeWaiting = true;
         }
         else
         {
            this.bagComplete = true;
         }
      }
      
      private function clipConsumptionCompleteCallback(param1:AnimClipDef) : void
      {
         var _loc2_:Function = null;
         if(!this.clipConsumeWaiting)
         {
            return;
         }
         --this.clipConsumeWaits;
         if(this.clipConsumeWaits == 0)
         {
            this.bagComplete = true;
            this.clipConsumeWaiting = false;
            _loc2_ = this.bagCompleteCallback;
            this.bagCompleteCallback = null;
            if(_loc2_ != null)
            {
               _loc2_(this);
            }
         }
      }
      
      public function writeCache() : ByteArray
      {
         var _loc2_:AnimClipDef = null;
         var _loc3_:ByteArray = null;
         if(this.reduction >= 1 || this.reduction <= 0)
         {
            return null;
         }
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeUnsignedInt(this.cacheKey);
         _loc1_.writeFloat(this.reduction);
         for each(_loc2_ in this.clips)
         {
            _loc2_.writeBytes(_loc1_);
            _loc3_ = _loc2_.reduceSheet();
            if(_loc3_)
            {
               _loc1_.writeBytes(_loc3_);
            }
         }
         return _loc1_;
      }
   }
}

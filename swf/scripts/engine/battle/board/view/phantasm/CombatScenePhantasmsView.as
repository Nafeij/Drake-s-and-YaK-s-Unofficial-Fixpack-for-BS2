package engine.battle.board.view.phantasm
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectEvent;
   import engine.battle.ability.phantasm.def.PhantasmDef;
   import engine.battle.ability.phantasm.def.PhantasmDefAnim;
   import engine.battle.ability.phantasm.def.PhantasmDefColorPulsator;
   import engine.battle.ability.phantasm.def.PhantasmDefFlyText;
   import engine.battle.ability.phantasm.def.PhantasmDefSound;
   import engine.battle.ability.phantasm.def.PhantasmDefSprite;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.ability.phantasm.model.ChainPhantasmsEvent;
   import engine.battle.ability.phantasm.model.PhantasmsEvent;
   import engine.battle.board.model.BattleBoardPhantasms;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.logging.ILogger;
   
   public class CombatScenePhantasmsView
   {
       
      
      private var sceneView:BattleBoardView;
      
      private var views:Vector.<PhantasmView>;
      
      private var boardPhantasms:BattleBoardPhantasms;
      
      private var logger:ILogger;
      
      private var eventChain:ChainPhantasms;
      
      private var chainEffect:Effect;
      
      public function CombatScenePhantasmsView(param1:BattleBoardView)
      {
         this.views = new Vector.<PhantasmView>();
         super();
         this.sceneView = param1;
         this.logger = param1.board.logger;
         this.boardPhantasms = param1.board.phantasms;
         this.boardPhantasms.addEventListener(PhantasmsEvent.CHAIN_STARTED,this.chainStartedHandler);
      }
      
      public function cleanup() : void
      {
         var _loc1_:PhantasmView = null;
         this.boardPhantasms.removeEventListener(PhantasmsEvent.CHAIN_STARTED,this.chainStartedHandler);
         if(this.eventChain)
         {
            this.eventChain.addEventListener(ChainPhantasmsEvent.PHANTASM,this.phantasmHandler);
            this.chainEffect = this.eventChain.effect;
            if(this.chainEffect)
            {
               this.chainEffect.addEventListener(EffectEvent.REMOVED,this.effectRemovedHandler);
               this.chainEffect = null;
            }
            this.eventChain = null;
         }
         for each(_loc1_ in this.views)
         {
            _loc1_.cleanup();
            _loc1_.chain.removeEventListener(ChainPhantasmsEvent.PHANTASM,this.phantasmHandler);
         }
         this.views = null;
         this.boardPhantasms = null;
         this.sceneView = null;
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:Vector.<PhantasmView> = null;
         var _loc5_:PhantasmView = null;
         var _loc6_:Boolean = false;
         var _loc3_:int = int(this.views.length - 1);
         var _loc4_:int = 0;
         while(_loc4_ <= _loc3_)
         {
            _loc5_ = this.views[_loc4_];
            _loc6_ = _loc5_.needsRemove || _loc5_.needsUpdate;
            if(!_loc6_ || _loc5_.needsUpdate && !_loc5_.update(param1))
            {
               _loc5_.cleanup();
               if(_loc3_ > _loc4_)
               {
                  this.views[_loc4_] = this.views[_loc3_];
               }
               _loc3_--;
            }
            else
            {
               _loc4_++;
            }
         }
         if(_loc3_ < this.views.length - 1)
         {
            this.views.splice(_loc3_ + 1,this.views.length - 1 - _loc3_);
         }
      }
      
      protected function chainStartedHandler(param1:PhantasmsEvent) : void
      {
         this.eventChain = param1.chain;
         if(this.eventChain)
         {
            this.eventChain.addEventListener(ChainPhantasmsEvent.PHANTASM,this.phantasmHandler);
            this.chainEffect = this.eventChain.effect;
            if(this.chainEffect)
            {
               this.chainEffect.addEventListener(EffectEvent.REMOVED,this.effectRemovedHandler);
            }
         }
      }
      
      private function effectRemovedHandler(param1:EffectEvent) : void
      {
         var _loc3_:PhantasmView = null;
         var _loc2_:Effect = param1.target as Effect;
         _loc2_.removeEventListener(EffectEvent.REMOVED,this.effectRemovedHandler);
         for each(_loc3_ in this.views)
         {
            if(_loc3_.effect == _loc2_)
            {
               _loc3_.chain.removeEventListener(ChainPhantasmsEvent.PHANTASM,this.phantasmHandler);
               _loc3_.remove();
               _loc3_.needsRemove = false;
            }
         }
      }
      
      protected function phantasmHandler(param1:ChainPhantasmsEvent) : void
      {
         var _loc2_:ChainPhantasms = param1.chain;
         var _loc3_:PhantasmDef = param1.phantasmDef;
         var _loc4_:PhantasmView = this.createView(_loc2_,_loc3_);
         if(_loc4_)
         {
            _loc4_.execute();
            if(_loc4_.needsUpdate || _loc4_.needsRemove)
            {
               this.views.push(_loc4_);
            }
         }
      }
      
      public function createView(param1:ChainPhantasms, param2:PhantasmDef) : PhantasmView
      {
         var _loc3_:PhantasmView = null;
         if(param2 is PhantasmDefSprite)
         {
            _loc3_ = new PhantasmViewSprite(this.sceneView,param1,param2 as PhantasmDefSprite,true);
         }
         else if(param2 is PhantasmDefColorPulsator)
         {
            _loc3_ = new PhantasmViewColorPulsator(this.sceneView,param1,param2 as PhantasmDefColorPulsator);
         }
         else if(param2 is PhantasmDefFlyText)
         {
            _loc3_ = new PhantasmViewFlyText(this.sceneView,param1,param2 as PhantasmDefFlyText);
         }
         else if(param2 is PhantasmDefAnim)
         {
            _loc3_ = new PhantasmViewAnim(this.sceneView,param1,param2 as PhantasmDefAnim);
         }
         else if(param2 is PhantasmDefSound)
         {
            _loc3_ = new PhantasmViewSound(this.sceneView,param1,param2 as PhantasmDefSound);
         }
         if(!_loc3_)
         {
            this.sceneView.board.logger.error("createView failed to create PhantasmView for " + param2);
         }
         return _loc3_;
      }
   }
}

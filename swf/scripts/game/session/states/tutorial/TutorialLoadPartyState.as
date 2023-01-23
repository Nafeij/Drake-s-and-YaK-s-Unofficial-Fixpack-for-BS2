package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityListDefVars;
   import engine.entity.def.IEntityListDef;
   import engine.resource.def.DefWrangler;
   import game.session.GameState;
   import game.session.states.GameStateDataEnum;
   
   public class TutorialLoadPartyState extends GameState
   {
       
      
      private var wrangler:DefWrangler;
      
      public function TutorialLoadPartyState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         this.wrangler = new DefWrangler("common/tutorial/tutorial_party.json.z",config.logger,config.resman,this.wrangled);
         this.wrangler.load();
      }
      
      private function wrangled(param1:DefWrangler) : void
      {
         var _loc2_:IEntityListDef = new EntityListDefVars(config.context.locale,logger).fromJson(param1.vars,config.logger,config.abilityFactory,config.classes,config,true,config.itemDefs);
         data.setValue(GameStateDataEnum.LOCAL_PARTY,_loc2_);
         phase = StatePhase.COMPLETED;
      }
   }
}

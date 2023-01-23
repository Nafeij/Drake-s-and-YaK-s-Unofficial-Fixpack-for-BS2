package engine.entity.def
{
   import engine.core.util.Enum;
   
   public class EntityIconType extends Enum
   {
      
      public static const SUBST_SRC:String = ".icon.";
      
      public static const INIT_ORDER:EntityIconType = new EntityIconType("INIT_ORDER",".icon.init.order.",enumCtorKey);
      
      public static const INIT_ACTIVE:EntityIconType = new EntityIconType("INIT_ACTIVE",".icon.init.active.",enumCtorKey);
      
      public static const PARTY:EntityIconType = new EntityIconType("PARTY",".icon.party.",enumCtorKey);
      
      public static const ROSTER:EntityIconType = new EntityIconType("ROSTER",".icon.roster.",enumCtorKey);
      
      public static const VERSUS:EntityIconType = new EntityIconType("VERSUS",".icon.versus.",enumCtorKey);
       
      
      private var subst:String;
      
      public function EntityIconType(param1:String, param2:String, param3:Object)
      {
         super(param1,param3);
         this.subst = param2;
      }
      
      public function transform(param1:String) : String
      {
         return param1.replace(SUBST_SRC,this.subst);
      }
      
      public function untransform(param1:String) : String
      {
         return param1.replace(this.subst,SUBST_SRC);
      }
   }
}

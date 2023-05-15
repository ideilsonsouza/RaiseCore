program RaiseCore;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  zcomponent,
  indylaz,
  // Core Model
  Core.Model.Consts,
  Core.Model.Data,
  Core.Model.GenFiles,
  Core.Model.JSON,
  Core.Model.Mesagens,
  //Core Controller
  Core.Controller.Data,
  Core.Controller.Encrypt,
  Core.Controller.Encode64,
  //Core Views
  Core.View.Forms,

  //App Views
  App.View.Form;

{$R *.res}
begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TAppViewForm, AppViewForm);
  Application.Run;

end.


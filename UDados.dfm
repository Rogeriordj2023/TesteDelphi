object DataModule1: TDataModule1
  Height = 480
  Width = 640
  object FDConnection1: TFDConnection
    Params.Strings = (
      'User_Name=postgres'
      'Password=postgres'
      'Database=postgres'
      'Server=localhost'
      'DriverID=PG'
      'POOL_MaximumItems=50000'
      'ExtendedMetadata=True')
    Connected = True
    LoginPrompt = False
    Left = 200
    Top = 64
  end
  object FDQuery1: TFDQuery
    Active = True
    Connection = FDConnection1
    SQL.Strings = (
      'select * from pessoa')
    Left = 296
    Top = 64
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    DriverID = 'PG'
    Left = 80
    Top = 64
  end
end

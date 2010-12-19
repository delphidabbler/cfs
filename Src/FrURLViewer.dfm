inherited URLViewerFrame: TURLViewerFrame
  inherited pnlView: TPanel
    inherited lblName: TLabel
      Width = 22
      Caption = 'URL'
    end
  end
  inherited alView: TActionList
    inherited actExec: TAction
      Caption = 'Go to URL'
      OnExecute = actExecExecute
    end
  end
end

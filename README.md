# NoteDetection

## API:

```
public class NoteDetection {

    public var onInputLevelChanged: NoteDetection.InputLevelChangedCallback?

    public init(type: NoteDetection.InputType) throws

    public var inputType: NoteDetection.InputType
}
```
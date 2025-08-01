# UI framework rules for SwiftUI

1. State Management:
   - Use @Observable for reference types holding business logic and app state.  
   - Use @Bindable properties within @Observable classes so SwiftUI views can bind directly to them.
   - Avoid @State for view model observation, rely on let model: MyModel instead.  
   - Pass dependencies via initialisers rather than as global singletons.  
   - Use @Environment for app-wide or large-scope states.  
   - @State is only for view-local state.
   - Use @Binding only if necessary
   - Prevent using @StateObject, @ObservedObject, @Published, ObservableObject, @EnvironmentObject

2. Modern Navigation:
   - Use NavigationSplitView for multi-column layouts on larger displays.  
   - Use NavigationStack with type-safe navigation for simpler or single-column apps.  
   - Use navigationDestination() for programmatic navigation and deep linking.

3. Layout System:
   - Use Grid for complex, flexible layouts.  
   - ViewThatFits for adaptive interfaces.  
   - Custom layouts via the Layout protocol.  
   - Apply containerRelativeFrame() for responsive sizing and positioning.  
   - Ensure Dynamic Type support in text and layouts.

4. Performance:
   - Annotate UI-updating code paths with @MainActor.  
   - Use TaskGroup for concurrent operations.  
   - Implement lazy loading (LazyVStack, LazyHGrid) with stable, identifiable items to boost performance.

5. UI Components:
   - Use ScrollView with .scrollTargetBehavior() for a better scrolling experience.  
   - Employ .contentMargins() for consistent internal spacing.  
   - Apply .containerShape() to customise hit testing areas.  
   - Use SF Symbols 5 with variable-colour and variable-width glyphs where appropriate.  
   - Extract reusable functionality into custom ViewModifiers.

6. Interaction & Animation:
   - Trigger visual changes with .animation(value:).  
   - Use Phase Animations for more complex transitions.  
   - Leverage .symbolEffect() for SF Symbol animations.  
   - Include .sensoryFeedback() for haptic or audio cues.  
   - Utilise SwiftUI gesture system for touch interactions.

7. Accessibility:
   - Every UI element must have an appropriate .accessibilityLabel(), .accessibilityHint(), and traits.  
   - Support VoiceOver by making sure views are .accessibilityElement() where needed.  
   - Implement Dynamic Type and test with larger text sizes.  
   - Provide clear, descriptive accessibility text for all elements.  
   - Respect reduced motion settings and provide alternatives if needed.

8. Reserved words
   - Prevent using Task as type name in favor of Swift Concurrency

9. Simple app architecture
   - All the files are located in the same app
   - Source codes can be found in the same app target
   - Do not use SPM, modules and frameworks to organize code
   - Prevent using syntax like @_exported import or @_implementationOnly import

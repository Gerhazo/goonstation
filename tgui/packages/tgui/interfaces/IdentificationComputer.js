import { useBackend, useLocalState } from '../backend';
import { Tabs, Box, BlockQuote, Button, LabeledList, Divider, Icon, NoticeBox, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

export const IdentificationComputer = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    authentication_card,
    modified_card,
    is_authenticated,
    id_computer_process_data,
  } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);
  return (
    <Window>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}>
            Tab one
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}>
            Tab two
          </Tabs.Tab>
        </Tabs>
        <Box>
          Tab selected: {tabIndex}
        </Box>
      </Window.Content>
    </Window>
  );
};

import { useBackend, useLocalState } from '../backend';
import { Tabs, Box, Dropdown, BlockQuote, Button, LabeledList, Divider, Icon, NoticeBox, NumberInput, Section, Stack, Flex } from '../components';
import { Window } from '../layouts';

export const IdentificationComputer = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    authentication_card_data,
    modified_card_data,
    is_authenticated,
    id_computer_process_data,
    selected_main_tab_index,
  } = data;
  return (
    <Window
      width={670}
      height={640}
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={selected_main_tab_index === 1}
            onClick={() => act('set_main_tab_index', { index: 1 })}>
            Authentication
          </Tabs.Tab>
          {!!is_authenticated && (
            <>
              <Tabs.Tab
                selected={selected_main_tab_index === 2}
                onClick={() => act('set_main_tab_index', { index: 2 })}>
                Tab two
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected_main_tab_index === 3}
                onClick={() => act('set_main_tab_index', { index: 3 })}>
                Tab three
              </Tabs.Tab>
            </>
          )}
        </Tabs>
        <Box>
          {(selected_main_tab_index === 1) && <TabOneContent />}
          {(selected_main_tab_index === 2) && <TabTwoContent />}
        </Box>
      </Window.Content>
    </Window>
  );
};

const TabOneContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
    is_authenticated,
    modified_card_data,
  } = data;

  return (
    <>
      <Section
        title="Authentication"
      >
        <Stack vertical>
          {!authentication_card_data && !is_authenticated && <AuthenticationPanelNotAuthenticated />}
          {authentication_card_data && !is_authenticated && <AuthenticationPanelAuthenticationFailed />}
          {authentication_card_data && is_authenticated && <AuthenticationPanelAuthenticationSuccess />}
        </Stack>
      </Section>
      <Section
        title="Auxillary Inputs"
      >
        <Stack vertical>
          <Stack.Item>
            <strong>Target modification ID: </strong>
            <Button
              icon={modified_card_data ? "id-card" : "eject"}
              onClick={() => act('insert_target_id')}
            >
              {modified_card_data ? ("Eject ID: " + modified_card_data.name) : "Insert ID"}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

const TabTwoContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
    is_authenticated,
    modified_card_data,
    id_computer_process_data,
    all_job_selections,
  } = data;

  return (
    <>
      <Section>
        <strong>Target modification ID: </strong>
        <Button
          icon={modified_card_data ? "id-card" : "eject"}
          onClick={() => act('insert_target_id')}
        >
          {modified_card_data ? ("Eject ID: " + modified_card_data.name) : "Insert ID"}
        </Button>
      </Section>
      <Section
        title="Identification"
      >
        <Stack vertical>
          <Stack.Item>
            Registered:
            <Button
              onClick={() => act('insert_target_id')}
            >
              {modified_card_data?.registered}
            </Button>
          </Stack.Item>
          <Stack.Item>
            Assignment:
            <Button
              onClick={() => act('insert_target_id')}
            >
              {modified_card_data?.assignment}
            </Button>
          </Stack.Item>
          <Stack.Item>
            PIN:
            <Button
              onClick={() => act('insert_target_id')}
            >
              ****
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section
        title="Jobs"
      >
        <Stack>
          <Stack.Item>
            <Dropdown
              options={all_job_selections}
              width={12}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon=""
              onClick={() => act('insert_target_id')}
            >
              Set
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => act('insert_target_id')}
            >
              Add access
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="minus"
              onClick={() => act('insert_target_id')}
            >
              Subtract access
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section
        title="Access"
      >
        access
      </Section>
    </>
  );
};

const AuthenticationPanelNotAuthenticated = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
  } = data;

  return (
    <>
      <Stack.Item>
        <NoticeBox info>
          You must insert your ID to continue!
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <strong>Authentication ID: </strong>
        <Button
          icon="eject"
          onClick={() => act('insert_authentication_id')}
        >
          {"Insert ID"}
        </Button>
      </Stack.Item>
      <Stack.Item>
        No ID has been detected. The machine&apos;s functionality is locked down.
      </Stack.Item>
    </>
  );
};

const AuthenticationPanelAuthenticationFailed = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
  } = data;

  return (
    <>
      <Stack.Item>
        <NoticeBox danger>
          Authentication failed. Access denied.
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <strong>Authentication ID: </strong>
        <Button
          icon="id-card"
          onClick={() => act('insert_authentication_id')}
        >
          {("Eject ID: " + authentication_card_data.name)}
        </Button>
      </Stack.Item>
      <Stack.Item>
        The inserted ID has insufficient clearance to allow for operation of the console.
        The machine&apos;s functionality remains locked down. Please contact higher clearance personnel.
      </Stack.Item>
    </>
  );
};

const AuthenticationPanelAuthenticationSuccess = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
  } = data;

  return (
    <>
      <Stack.Item>
        <NoticeBox success>
          Authentication successful. Access granted.
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <strong>Authentication ID: </strong>
        <Button
          icon="id-card"
          onClick={() => act('insert_authentication_id')}
        >
          {("Eject ID: " + authentication_card_data.name)}
        </Button>
      </Stack.Item>
      <Stack.Item>
        The inserted ID has sufficient clearance to allow for operation of the console.
        The machine&apos;s functionality has been unlocked.
      </Stack.Item>
    </>
  );
};
